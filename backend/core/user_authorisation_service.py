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

from backend.core.logger import logger
from backend.core.value_error_exception import ValueErrorException
from backend.settings import config
from backend.users.enums.token import Token
from backend.users.mappers import decoded_token_to_payload
from backend.users.schemas import RefreshTokensResponse, TokenPayload

security = HTTPBearer()


class AuthorizationService:
    def __init__(self, redis: aioredis):
        if not redis:
            logger.error("Redis connection error")
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
                "role": data.get("role"),
            }
        )

        refresh_token_data = data.copy()
        refresh_token_data.update(
            {
                "jti": refresh_token_jti,
                "linked_jti": access_token_jti,
                "exp": refresh_token_expire,
                "type": Token.REFRESH.value,
                "role": data.get("role"),
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
        token = await self.verify_refresh_token(refresh_token)

        refresh_token_jti = token.jti
        access_token_jti = token.linked_jti

        new_access_token, new_refresh_token = await self.create_tokens(
            {"sub": token.email, "id": token.id, "role": token.role}
        )

        await self.revoke_tokens(refresh_token_jti, access_token_jti)

        return RefreshTokensResponse(
            id=token.id,
            email=token.email,
            access_token=new_access_token,
            refresh_token=new_refresh_token,
        )

    async def verify_access_token(
        self,
        credentials: HTTPAuthorizationCredentials = Security(security),
    ) -> TokenPayload:
        return await self.verify_token_by_type(credentials, Token.ACCESS.value)

    async def verify_refresh_token(
        self,
        credentials: HTTPAuthorizationCredentials = Security(security),
    ) -> TokenPayload:
        return await self.verify_token_by_type(credentials, Token.REFRESH.value)

    async def verify_token_by_type(
        self,
        credentials: HTTPAuthorizationCredentials,
        expected_type: str,
    ) -> TokenPayload:
        token = await self.get_payload_from_token(credentials, expected_type)

        if token.type != expected_type:
            logger.debug(f"Invalid token type. Expected {expected_type}.")

            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED
                if Token.ACCESS.value == token.type
                else status.HTTP_403_FORBIDDEN,
                detail=f"Invalid token type. Expected {expected_type}.",
            )

        redis_key = token.jti if expected_type == Token.REFRESH.value else token.linked_jti
        stored_token = await self.redis.get(redis_key)

        if not stored_token:
            logger.debug("Invalid token")

            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid token",
            )

        async with self.redis.pipeline() as pipe:
            pipe.exists(f"blacklist:{token.jti}")
            if token.linked_jti:
                pipe.exists(f"blacklist:{token.linked_jti}")
            revoked_results = await pipe.execute()

        if any(revoked_results):
            logger.debug("Revoked token")
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED
                if Token.ACCESS.value == token.type
                else status.HTTP_403_FORBIDDEN,
                detail="Revoked token",
            )

        return token

    async def get_payload_from_token(
        self,
        credentials: HTTPAuthorizationCredentials = Security(security),
        token_type: str = None,
    ) -> TokenPayload:
        try:
            return decoded_token_to_payload(
                jwt.decode(
                    credentials.credentials,
                    config.SECRET_KEY,
                    algorithms=[config.ALGORITHM],
                )
            )
        except (jwt.ExpiredSignatureError, jwt.InvalidTokenError) as e:
            logger.debug("Revoked token")
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED
                if Token.ACCESS.value == token_type
                else status.HTTP_403_FORBIDDEN,
                detail="Revoked token",
            ) from e

    async def extract_email_from_base64(self, token: str) -> str | None:
        try:
            decoded = await self.decode_token(token)
            email = re.search(rb"[\w.-]+@[\w.-]+", decoded)

            return email.group(0).decode("utf-8")
        except Exception:
            return None

    async def extract_language_from_base64(self, token: str) -> str | None:
        try:
            decoded = await self.decode_token(token)
            language = re.search(rb'"language":"(.*?)"', decoded)

            return language.group(0).decode("utf-8")['"language":"'.__len__() : -1]
        except Exception:
            return None

    async def decode_token(self, token):
        padding = len(token) % 4
        if padding:
            token += "=" * (4 - padding)
        decoded = base64.urlsafe_b64decode(token)
        return decoded

    async def get_serializer(self, salt: str = config.NEW_ACCOUNT_SALT):
        await self.verify_salt(salt)

        return URLSafeTimedSerializer(secret_key=config.SECRET_KEY, salt=salt)

    async def verify_salt(self, salt):
        if salt not in config.SALTS:
            raise ValueErrorException("Invalid salt value.")

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
            logger.debug("Token verification failed")
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Token verification failed",
            ) from e
