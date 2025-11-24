from datetime import datetime
from uuid import UUID

from fastapi import HTTPException, status
from pydantic import EmailStr

from backend.core.logger import logger
from backend.core.not_found_in_database_exception import NotFoundInDatabaseException
from backend.models import User
from backend.settings import config
from backend.users.user_repository import UserRepository


class UserValidationService:
    def __init__(self, user_repository: UserRepository):
        self.user_repository = user_repository

    def ensure_verified_user(self, user) -> User:
        if not user.is_verified:
            logger.debug("User has not been verified")
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="EMAIL_NOT_VERIFIED",
                headers={"X-Error-Code": "EMAIL_NOT_VERIFIED"},
            )
        return user

    def check_user_permission(self, user_param_from_token, user_param_from_request):
        if str(user_param_from_token) != str(user_param_from_request):
            logger.debug("Invalid token for the user")
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Invalid token",
            )

    def check_last_password_change_data_time(self, user):
        time_diff = (datetime.now(config.TIMEZONE) - user.last_password_update).total_seconds()
        if time_diff < config.RESET_PASSWORD_OFFSET_SECONDS:
            logger.debug("Password was changed too recently")
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail=f"You must wait at least 1 day before changing your password again,"
                f" last changed at {user.last_password_update}",
            )

    async def ensure_user_exists_by_email(self, email: EmailStr) -> User:
        user = await self.user_repository.get_user_by_email(email)
        if not user:
            logger.debug("User not found by email")
            raise NotFoundInDatabaseException("User not found")

        return user

    async def ensure_user_exists_by_id(self, user_id: UUID) -> User:
        user = await self.user_repository.get_user_by_id(user_id)
        if not user:
            logger.debug("User not found by id")
            raise NotFoundInDatabaseException("User not found")

        return user
