from fastapi import Depends
from pydantic import EmailStr

from backend.models import User
from backend.users.auth_dependencies import AuthDependency
from backend.users.dependencies import get_user_validators
from backend.users.service.user_validation_service import (
    UserValidationService,
)


class UserGateway:
    def __init__(
        self,
        auth_dependency: AuthDependency,
        user_validation_service: UserValidationService,
    ):
        self.auth_dependency = auth_dependency
        self.user_validation_service = user_validation_service

    async def ensure_user_exists_by_email(self, email: EmailStr) -> User:
        return await self.user_validation_service.ensure_user_exists_by_email(email)

    async def ensure_user_exists_by_id(self, user_id: int) -> User:
        return await self.user_validation_service.ensure_user_exists_by_id(user_id)

    async def get_current_user(self) -> tuple[User, dict]:
        return await self.auth_dependency.get_current_user()

    def check_user_permission(self, user_param_from_token, user_param_from_request) -> None:
        self.user_validation_service.check_user_permission(user_param_from_token, user_param_from_request)


def get_user_gateway(
    user_validation_service: UserValidationService = Depends(get_user_validators),
    auth_dependency: AuthDependency = Depends(AuthDependency),
) -> UserGateway:
    return UserGateway(auth_dependency, user_validation_service)
