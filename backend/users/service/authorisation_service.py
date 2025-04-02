from datetime import datetime, timedelta

import redis.asyncio as aioredis
import jwt
from fastapi import HTTPException, Security, status
from fastapi.params import Depends
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from backend.Settings import (
    SECRET_KEY,
    ALGORITHM,
    ACCESS_TOKEN_EXPIRE_MINUTES,
    REFRESH_TOKEN_EXPIRE_HOURS,
)
from backend.core.database import get_redis

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

        access_token_expire = datetime.utcnow() + timedelta(
            minutes=ACCESS_TOKEN_EXPIRE_MINUTES
        )
        refresh_token_expire = datetime.utcnow() + timedelta(
            hours=REFRESH_TOKEN_EXPIRE_HOURS
        )

        access_token_data = data.copy()
        access_token_data.update({"exp": access_token_expire})

        refresh_token_data = data.copy()
        refresh_token_data.update({"exp": refresh_token_expire})

        access_token = jwt.encode(access_token_data, SECRET_KEY, algorithm=ALGORITHM)
        refresh_token = jwt.encode(refresh_token_data, SECRET_KEY, algorithm=ALGORITHM)

        await redis_tokens.setex(
            data["id"], ACCESS_TOKEN_EXPIRE_MINUTES * 60, access_token
        )

        return access_token, refresh_token

    @staticmethod
    async def delete_user_token(user_id):
        redis_tokens = await get_redis()

        if not redis_tokens:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail="Redis connection error",
            )

        return await redis_tokens.delete(user_id)

    @staticmethod
    async def refresh_access_token(
        refresh_token: HTTPAuthorizationCredentials = Security(security),
        redis_tokens: aioredis.Redis = Depends(get_redis),
    ):
        payload = await AuthorizationService.get_payload_from_token(refresh_token)
        user_id = payload.get("id")

        if not await redis_tokens.get(user_id):
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid token"
            )

        access_token_expire = datetime.utcnow() + timedelta(
            minutes=ACCESS_TOKEN_EXPIRE_MINUTES
        )
        payload["exp"] = access_token_expire
        refreshed_access_token = jwt.encode(payload, SECRET_KEY, algorithm=ALGORITHM)
        await redis_tokens.setex(
            payload["id"], ACCESS_TOKEN_EXPIRE_MINUTES * 60, refreshed_access_token
        )

        return refreshed_access_token

    @staticmethod
    async def verify_token(
        credentials: HTTPAuthorizationCredentials = Security(security),
        redis_tokens: aioredis.Redis = Depends(get_redis),
    ):
        token = await AuthorizationService.get_payload_from_token(credentials)
        stored_token = await redis_tokens.get(token.get("id"))

        if not stored_token or stored_token.decode("utf-8") != credentials.credentials:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid or revoked token",
            )

        return token

    @staticmethod
    async def get_payload_from_token(
        credentials: HTTPAuthorizationCredentials = Security(security),
    ):
        try:
            return jwt.decode(
                credentials.credentials, SECRET_KEY, algorithms=[ALGORITHM]
            )
        except (jwt.ExpiredSignatureError, jwt.InvalidTokenError):
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid token"
            )
