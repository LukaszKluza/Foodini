import base64
import re
import uuid
from datetime import datetime, timedelta
from typing import Any, Dict

import jwt
import redis.asyncio as aioredis
from fastapi import HTTPException, Security, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from itsdangerous import (
    BadData,
    BadSignature,
    BadTimeSignature,
    SignatureExpired,
    URLSafeTimedSerializer,
)

from backend.core.value_error_exception import ValueErrorException
from backend.settings import config
from backend.users.enums.token import Token
from backend.users.schemas import RefreshTokensResponse

security = HTTPBearer()


class AuthorizationService:
    def __init__(self, redis: aioredis):
        if not redis:
            raise HTTPException(500, "Redis connection error")
        self.redis = redis

    async def create_tokens(self, data: dict):
        access_token_expire = datetime.now(config.TIMEZONE) + timedelta(minutes=config.ACCESS_TOKEN_EXPIRE_MINUTES)
        refresh_token_expire = datetime.now(config.TIMEZONE) + timedelta(hours=config.REFRESH_TOKEN_EXPIRE_HOURS)

        access_token_jti = str(uuid.uuid4())
        refresh_token_jti = str(uuid.uuid4())

        access_token_data = data.copy()
        access_token_data.update(
            {
                "jti": access_token_jti,
                "linked_jti": refresh_token_jti,
                "exp": access_token_expire,
                "type": Token.ACCESS.value,
            }
        )

        refresh_token_data = data.copy()
        refresh_token_data.update(
            {
                "jti": refresh_token_jti,
                "linked_jti": access_token_jti,
                "exp": refresh_token_expire,
                "type": Token.REFRESH.value,
            }
        )

        access_token = jwt.encode(access_token_data, config.SECRET_KEY, algorithm=config.ALGORITHM)
        refresh_token = jwt.encode(refresh_token_data, config.SECRET_KEY, algorithm=config.ALGORITHM)

        await self.redis.setex(refresh_token_jti, config.REFRESH_TOKEN_EXPIRE_HOURS * 3600, refresh_token)

        return access_token, refresh_token

    async def revoke_tokens(self, token_jti: str, linked_token_jti: str):
        async with self.redis.pipeline() as pipe:
            await pipe.setex(
                f"blacklist:{token_jti}",
                config.REFRESH_TOKEN_EXPIRE_HOURS * 3600,
                Token.REVOKED.value,
            )
            await pipe.setex(
                f"blacklist:{linked_token_jti}",
                config.REFRESH_TOKEN_EXPIRE_HOURS * 3600,
                Token.REVOKED.value,
            )
            await pipe.execute()

    async def refresh_tokens(
        self,
        refresh_token: HTTPAuthorizationCredentials = Security(security),
    ) -> RefreshTokensResponse:
        payload = await self.verify_refresh_token(refresh_token)

        refresh_token_jti = payload.get("jti")
        access_token_jti = payload.get("linked_jti")

        new_access_token, new_refresh_token = await self.create_tokens({"sub": payload["sub"], "id": payload["id"]})

        await self.revoke_tokens(refresh_token_jti, access_token_jti)

        return RefreshTokensResponse(
            id=payload["id"],
            email=payload["sub"],
            access_token=new_access_token,
            refresh_token=new_refresh_token,
        )

    async def verify_access_token(
        self,
        credentials: HTTPAuthorizationCredentials = Security(security),
    ):
        return await self.verify_token_by_type(credentials, Token.ACCESS.value)

    async def verify_refresh_token(
        self,
        credentials: HTTPAuthorizationCredentials = Security(security),
    ):
        return await self.verify_token_by_type(credentials, Token.REFRESH.value)

    async def verify_token_by_type(
        self,
        credentials: HTTPAuthorizationCredentials,
        expected_type: str,
    ):
        token = await self.get_payload_from_token(credentials, expected_type)
        token_type = token.get("type")
        token_jti = token.get("jti")
        linked_jti = token.get("linked_jti")

        if token_type != expected_type:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED
                if Token.ACCESS.value == token_type
                else status.HTTP_403_FORBIDDEN,
                detail=f"Invalid token type. Expected {expected_type}.",
            )

        redis_key = token_jti if expected_type == "refresh" else linked_jti
        stored_token = await self.redis.get(redis_key)

        if not stored_token:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid token",
            )

        async with self.redis.pipeline() as pipe:
            pipe.exists(f"blacklist:{token_jti}")
            if linked_jti:
                pipe.exists(f"blacklist:{linked_jti}")
            revoked_results = await pipe.execute()

        if any(revoked_results):
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED
                if Token.ACCESS.value == token_type
                else status.HTTP_403_FORBIDDEN,
                detail="Revoked token",
            )

        return token

    async def get_payload_from_token(
        self,
        credentials: HTTPAuthorizationCredentials = Security(security),
        token_type: str = None,
    ):
        try:
            return jwt.decode(
                credentials.credentials,
                config.SECRET_KEY,
                algorithms=[config.ALGORITHM],
            )
        except (jwt.ExpiredSignatureError, jwt.InvalidTokenError) as e:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED
                if Token.ACCESS.value == token_type
                else status.HTTP_403_FORBIDDEN,
                detail="Revoked token",
            ) from e

    async def extract_email_from_base64(self, token: str) -> str | None:
        try:
            padding = len(token) % 4
            if padding:
                token += "=" * (4 - padding)

            decoded = base64.urlsafe_b64decode(token)
            match = re.search(rb"[\w.-]+@[\w.-]+", decoded)
            return match.group(0).decode("utf-8")
        except Exception:
            return None

    async def get_serializer(self, salt: str = config.NEW_ACCOUNT_SALT):
        await self.verify_salt(salt)

        return URLSafeTimedSerializer(secret_key=config.SECRET_KEY, salt=salt)

    async def verify_salt(self, salt):
        if salt not in config.SALTS:
            raise ValueErrorException(f"Invalid salt value. Use either {config.SALTS}.")

    async def create_url_safe_token(self, data: Dict[str, Any], salt: str = config.NEW_ACCOUNT_SALT):
        await self.verify_salt(salt)
        serializer = await self.get_serializer(salt)

        return serializer.dumps(data)

    async def decode_url_safe_token(self, token: str, salt: str = config.NEW_ACCOUNT_SALT):
        await self.verify_salt(salt)
        serializer = await self.get_serializer(salt)

        try:
            return serializer.loads(token, max_age=config.VERIFICATION_TOKEN_EXPIRE_MINUTES * 60)
        except (SignatureExpired, BadTimeSignature, BadSignature, BadData) as e:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Token verification failed",
            ) from e
