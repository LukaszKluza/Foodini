from fastapi import HTTPException, status, Depends
from datetime import datetime

from backend.users.user_repository import UserRepository, get_user_repository
from backend.users.models import User
from backend.settings import config


class UserValidationService:
    def __init__(self, user_repository: UserRepository = Depends(get_user_repository)):
        self.user_repository = user_repository

    def ensure_verified_user(self, user) -> User:
        if not user.is_verified:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Account not verified. Please check your email.",
            )
        return user

    def check_user_permission(
        self, user_param_from_token: int, user_param_from_request: int
    ):
        if user_param_from_token != user_param_from_request:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Invalid token",
            )

    def check_last_password_change_data_time(self, user):
        time_diff = (
            datetime.now(config.TIMEZONE) - user.last_password_update
        ).total_seconds()
        if time_diff < config.RESET_PASSWORD_OFFSET_SECONDS:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail=f"You must wait at least 1 day before changing your password again,"
                f" last changed at {user.last_password_update}",
            )

    async def ensure_user_exists_by_email(self, email: str) -> User:
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


def get_user_validators(
    user_repository: UserRepository = Depends(get_user_repository),
) -> UserValidationService:
    return UserValidationService(user_repository)
