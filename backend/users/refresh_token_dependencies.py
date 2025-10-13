from fastapi import HTTPException
from starlette import status
from starlette.requests import Request
from starlette.responses import Response

from backend.core.user_authorisation_service import AuthorizationService
from backend.settings import config
from backend.users.schemas import LoginUserResponse


class RefreshTokenDependency:
    def __init__(
        self,
        request: Request,
        authorization_service: AuthorizationService,
    ):
        self.request = request
        self.authorization_service = authorization_service

    async def get_refreshed_tokens(self) -> (LoginUserResponse, str):
        token = self.request.cookies.get("refresh_token")
        if not token:
            raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Missing refresh token")
        return await self.authorization_service.refresh_tokens(token)

    @staticmethod
    def set_refresh_token_cookie(response: Response, refresh_token: str):
        response.set_cookie(
            key="refresh_token",
            value=refresh_token,
            httponly=True,
            secure=True,
            samesite="strict",
            max_age=60 * 60 * config.REFRESH_TOKEN_EXPIRE_HOURS,
        )

    @staticmethod
    def delete_refresh_token_cookie(response: Response):
        response.delete_cookie(
            key="refresh_token",
            secure=True,
            samesite="strict",
        )
