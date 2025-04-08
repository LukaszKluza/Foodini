from fastapi import HTTPException, status
from datetime import datetime

from backend.users.user_repository import UserRepository
from backend.settings import config


class UserValidations:
    @staticmethod
    def ensure_verified_user(user):
        if not user.is_verified:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Account not verified. Please check your email.",
            )
        return user

    @staticmethod
    def check_user_permission(user_param_from_token: int, user_param_from_request: int):
        if user_param_from_token != user_param_from_request:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Invalid token",
            )

    @staticmethod
    def check_last_password_change_data_time(user):
        time_diff = (
            datetime.now(config.TIMEZONE) - user.last_password_update
        ).total_seconds()
        if time_diff < config.RESET_PASSWORD_OFFSET_SECONDS:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail=f"You must wait at least 1 day before changing your password again,"
                f" last changed at {user.last_password_update}",
            )

    @staticmethod
    async def ensure_user_exists_by_email(user_repository: UserRepository, email: str):
        user = await user_repository.get_user_by_email(email)
        if not user:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="User does not exist",
            )
        return user

    @staticmethod
    async def ensure_user_exists_by_id(user_repository: UserRepository, user_id: int):
        user = await user_repository.get_user_by_id(user_id)
        if not user:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="User does not exist",
            )
        return user
