from typing import Type

from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer

from backend.core.user_authorisation_service import AuthorizationService
from backend.models import User
from backend.users.service.user_validation_service import UserValidationService

security = HTTPBearer()


class AuthDependency:
    def __init__(
        self,
        user_id: int,
        credentials: HTTPAuthorizationCredentials | str,
        user_validators: UserValidationService,
        authorization_service: AuthorizationService,
    ):
        self.user_id = user_id
        self.credentials = credentials
        self.user_validators = user_validators
        self.authorization_service = authorization_service

    async def get_token_payload(self) -> dict:
        return await self.authorization_service.verify_access_token(self.credentials)

    async def get_current_user(self) -> tuple[Type[User], dict]:
        token_payload = await self.get_token_payload()
        user_id_from_token = token_payload["id"]

        self.user_validators.check_user_permission(user_id_from_token, self.user_id)
        user = await self.user_validators.ensure_user_exists_by_id(user_id_from_token)
        self.user_validators.ensure_verified_user(user)

        return user, token_payload
