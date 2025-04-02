from datetime import datetime, timedelta
import redis.asyncio as aioredis
import jwt
from itsdangerous import URLSafeTimedSerializer
from fastapi import HTTPException, Security, status
from fastapi.params import Depends
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials

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

        access_token_data = data.copy()
        access_token_data.update({"exp": access_token_expire})

        refresh_token_data = data.copy()
        refresh_token_data.update({"exp": refresh_token_expire})

        access_token = jwt.encode(
            access_token_data, config.SECRET_KEY, algorithm=config.ALGORITHM
        )
        refresh_token = jwt.encode(
            refresh_token_data, config.SECRET_KEY, algorithm=config.ALGORITHM
        )

        await redis_tokens.setex(
            data["id"], config.ACCESS_TOKEN_EXPIRE_MINUTES * 60, access_token
        )

        return access_token, refresh_token

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

        access_token_expire = datetime.now(config.TIMEZONE) + timedelta(
            minutes=config.ACCESS_TOKEN_EXPIRE_MINUTES
        )
        payload["exp"] = access_token_expire
        refreshed_access_token = jwt.encode(
            payload, config.SECRET_KEY, algorithm=config.ALGORITHM
        )
        await redis_tokens.setex(
            payload["id"],
            config.ACCESS_TOKEN_EXPIRE_MINUTES * 60,
            refreshed_access_token,
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
                credentials.credentials,
                config.SECRET_KEY,
                algorithms=[config.ALGORITHM],
            )
        except (jwt.ExpiredSignatureError, jwt.InvalidTokenError):
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid token"
            )

    @staticmethod
    async def create_url_safe_token(data: dict):
        serializer = URLSafeTimedSerializer(
            secret_key=config.SECRET_KEY, salt=config.PEPPER_KEY
        )

        return serializer.dumps(data)

    @staticmethod
    async def decode_url_safe_token(token: str):
        serializer = URLSafeTimedSerializer(
            secret_key=config.SECRET_KEY, salt=config.PEPPER_KEY
        )

        try:
            return serializer.loads(token)
        except Exception as e:
            raise HTTPException(status_code=400, detail=str(e))
