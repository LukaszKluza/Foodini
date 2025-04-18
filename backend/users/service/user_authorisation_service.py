from datetime import datetime, timedelta
import redis.asyncio as aioredis
import jwt
import uuid
from itsdangerous import (
    URLSafeTimedSerializer,
    SignatureExpired,
    BadSignature,
    BadTimeSignature,
    BadData,
)
from fastapi import HTTPException, Security, status
from fastapi.params import Depends
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from typing import Dict, Any

from backend.core.database import get_redis
from backend.settings import config


security = HTTPBearer()


class AuthorizationService:
    @staticmethod
    async def create_tokens(data: dict):
        redis_tokens = await get_redis()

        if not redis_tokens:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail="Redis connection error",
            )

        access_token_expire = datetime.now(config.TIMEZONE) + timedelta(
            minutes=config.ACCESS_TOKEN_EXPIRE_MINUTES
        )
        refresh_token_expire = datetime.now(config.TIMEZONE) + timedelta(
            hours=config.REFRESH_TOKEN_EXPIRE_HOURS
        )

        access_token_jti = str(uuid.uuid4)
        refresh_token_jti = str(uuid.uuid4)

        access_token_data = data.copy()
        access_token_data.update(
            {
                "jti": access_token_jti,
                "linked_jti": refresh_token_jti,
                "exp": access_token_expire,
            }
        )

        refresh_token_data = data.copy()
        refresh_token_data.update(
            {
                "jti": refresh_token_jti,
                "linked_jti": access_token_jti,
                "exp": refresh_token_expire,
            }
        )

        access_token = jwt.encode(
            access_token_data, config.SECRET_KEY, algorithm=config.ALGORITHM
        )
        refresh_token = jwt.encode(
            refresh_token_data, config.SECRET_KEY, algorithm=config.ALGORITHM
        )

        await redis_tokens.setex(
            refresh_token_jti, config.REFRESH_TOKEN_EXPIRE_HOURS * 3600, refresh_token
        )

        return access_token, refresh_token

    @staticmethod
    async def revoke_tokens(token_jti: str, linked_token_jti: str):
        redis_tokens = await get_redis()

        if not redis_tokens:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail="Redis connection error",
            )

        async with redis_tokens.pipeline() as pipe:
            await (
                pipe.setex(
                    f"blacklist:{token_jti}",
                    config.REFRESH_TOKEN_EXPIRE_HOURS * 3600,
                    "revoked",
                )
                .setex(
                    f"blacklist:{linked_token_jti}",
                    config.REFRESH_TOKEN_EXPIRE_HOURS * 3600,
                    "revoked",
                )
                .execute()
            )

    @staticmethod
    async def refresh_access_token(
        refresh_token: HTTPAuthorizationCredentials = Security(security),
        redis_tokens: aioredis.Redis = Depends(get_redis),
    ):
        payload = await AuthorizationService.get_payload_from_token(refresh_token)
        refresh_token_jti = payload.get("jti")
        access_token_jti = payload.get("linked_jti")

        if not await redis_tokens.get(refresh_token_jti):
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid token"
            )

        new_access_token, new_refresh_token = await AuthorizationService.create_tokens(
            {"sub": payload["sub"], "id": payload["id"]}
        )

        await AuthorizationService.revoke_tokens(refresh_token_jti, access_token_jti)

        return new_access_token, new_refresh_token

    @staticmethod
    async def verify_token(
        credentials: HTTPAuthorizationCredentials = Security(security),
        redis_tokens: aioredis.Redis = Depends(get_redis),
    ):
        token = await AuthorizationService.get_payload_from_token(credentials)
        token_jti = token.get("jti")
        linked_jti = token.get("linked_jti")

        stored_token = await redis_tokens.get(token_jti)
        stored_linked_token = await redis_tokens.get(linked_jti)

        if not stored_linked_token and not stored_token:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid token",
            )

        async with redis_tokens.pipeline() as pipe:
            pipe.exists(f"blacklist:{token_jti}")
            if linked_jti:
                pipe.exists(f"blacklist:{linked_jti}")
            revoked_results = await pipe.execute()

        is_revoked = any(revoked_results)
        if is_revoked:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Revoked token",
            )

        return token

    @staticmethod
    async def get_payload_from_token(
        credentials: HTTPAuthorizationCredentials = Security(security),
    ):
        try:
            return jwt.decode(
                credentials.credentials,
                config.SECRET_KEY,
                algorithms=[config.ALGORITHM],
            )
        except (jwt.ExpiredSignatureError, jwt.InvalidTokenError):
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid token"
            )

    @staticmethod
    async def get_serializer(salt: str = config.NEW_ACCOUNT_SALT):
        await AuthorizationService.verify_salt(salt)

        return URLSafeTimedSerializer(secret_key=config.SECRET_KEY, salt=salt)

    @staticmethod
    async def verify_salt(salt):
        if salt not in config.SALTS:
            raise ValueError(f"Invalid salt value. Use either {config.SALTS}.")

    @staticmethod
    async def create_url_safe_token(
        data: Dict[str, Any], salt: str = config.NEW_ACCOUNT_SALT
    ):
        await AuthorizationService.verify_salt(salt)
        serializer = await AuthorizationService.get_serializer(salt)

        return serializer.dumps(data)

    @staticmethod
    async def decode_url_safe_token(token: str, salt: str = config.NEW_ACCOUNT_SALT):
        await AuthorizationService.verify_salt(salt)
        serializer = await AuthorizationService.get_serializer(salt)

        try:
            return serializer.loads(
                token, max_age=config.VERIFICATION_TOKEN_EXPIRE_MINUTES * 60
            )
        except (SignatureExpired, BadTimeSignature, BadSignature, BadData):
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Token verification failed",
            )
