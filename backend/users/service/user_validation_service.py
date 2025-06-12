from datetime import datetime

from fastapi import HTTPException, status
from pydantic import EmailStr

from backend.models import User
from backend.settings import config
from backend.users.user_repository import UserRepository


class UserValidationService:
    def __init__(self, user_repository: UserRepository):
        self.user_repository = user_repository

    @classmethod
    def ensure_verified_user(cls, user) -> User:
        if not user.is_verified:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="EMAIL_NOT_VERIFIED",
                headers={"X-Error-Code": "EMAIL_NOT_VERIFIED"},
            )
        return user

    @classmethod
    def check_user_permission(cls, user_param_from_token, user_param_from_request):
        if user_param_from_token != user_param_from_request:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Invalid token",
            )

    @classmethod
    def check_last_password_change_data_time(cls, user):
        time_diff = (
            datetime.now(config.TIMEZONE) - user.last_password_update
        ).total_seconds()
        if time_diff < config.RESET_PASSWORD_OFFSET_SECONDS:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail=f"You must wait at least 1 day before changing your password again,"
                f" last changed at {user.last_password_update}",
            )

    async def ensure_user_exists_by_email(self, email: EmailStr) -> User:
        user = await self.user_repository.get_user_by_email(email)
        if not user:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="User does not exist",
            )
        return user

    async def ensure_user_exists_by_id(self, user_id: int) -> User:
        user = await self.user_repository.get_user_by_id(user_id)
        if not user:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="User does not exist",
            )
        return user
