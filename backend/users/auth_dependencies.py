from typing import List, Type
from uuid import UUID

from fastapi import Depends, HTTPException
from starlette import status

from backend.core.security import oauth2_scheme
from backend.core.user_authorisation_service import AuthorizationService
from backend.models import User
from backend.users.enums.role import Role
from backend.users.schemas import RefreshTokensResponse, TokenPayload
from backend.users.service.user_validation_service import UserValidationService


class AuthDependency:
    def __init__(
        self,
        user_id: UUID,
        user_validators: UserValidationService,
        authorization_service: AuthorizationService,
        token: str = Depends(oauth2_scheme),
    ):
        self.user_id = user_id
        self.token = token
        self.user_validators = user_validators
        self.authorization_service = authorization_service

    async def get_token_payload(self) -> TokenPayload:
        return await self.authorization_service.verify_access_token(self.token)

    async def get_current_user(self) -> tuple[Type[User], TokenPayload]:
        token_payload = await self.get_token_payload()
        user_id_from_token = token_payload.id

        self.user_validators.check_user_permission(user_id_from_token, self.user_id)
        user = await self.user_validators.ensure_user_exists_by_id(user_id_from_token)
        self.user_validators.ensure_verified_user(user)

        return user, token_payload

    async def require_roles(self, allowed_roles: List[Role]) -> TokenPayload:
        payload = await self.get_token_payload()
        if payload.role not in allowed_roles:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Insufficient permissions",
            )
        return payload

    async def get_refreshed_tokens(self) -> RefreshTokensResponse:
        return await self.authorization_service.refresh_tokens(self.token)
