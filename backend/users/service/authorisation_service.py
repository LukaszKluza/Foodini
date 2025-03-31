from datetime import datetime, timedelta

import jwt
from fastapi import HTTPException, Security
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from backend.Settings import (
    SECRET_KEY,
    ALGORITHM,
    ACCESS_TOKEN_EXPIRE_MINUTES,
    REFRESH_TOKEN_EXPIRE_HOURS,
)
from backend.core.database import redis_tokens

security = HTTPBearer()


class AuthorizationService:
    @staticmethod
    async def create_tokens(data: dict):
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
    async def refresh_access_token(
        refresh_token: HTTPAuthorizationCredentials = Security(security),
    ):
        payload = await AuthorizationService.get_payload_from_token(refresh_token)
        user_id = payload.get("id")

        if not await redis_tokens.get(user_id):
            raise HTTPException(status_code=401, detail="Invalid token")

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
    ):
        token = await AuthorizationService.get_payload_from_token(credentials)
        stored_token = await redis_tokens.get(token.get("id"))

        if stored_token.decode("utf-8") != credentials:
            raise HTTPException(status_code=401, detail="Token revoked")

        try:
            return token
        except jwt.ExpiredSignatureError:
            raise HTTPException(status_code=401, detail="Token expired")
        except jwt.InvalidTokenError:
            raise HTTPException(status_code=401, detail="Invalid token")

    @staticmethod
    async def get_payload_from_token(
        credentials: HTTPAuthorizationCredentials = Security(security),
    ):
        credentials = credentials.credentials
        token = jwt.decode(credentials, SECRET_KEY, algorithms=[ALGORITHM])

        try:
            return token
        except jwt.ExpiredSignatureError:
            raise HTTPException(status_code=401, detail="Token expired")
        except jwt.InvalidTokenError:
            raise HTTPException(status_code=401, detail="Invalid token")
