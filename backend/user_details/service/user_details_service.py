from fastapi import HTTPException, status
from fastapi.params import Depends

from backend.user_details.schemas import UserDetailsCreate, UserDetailsUpdate
from backend.user_details.service.user_details_validation_service import (
    UserDetailsValidationService,
    get_user_details_validators,
)
from backend.user_details.user_details_repository import (
    UserDetailsRepository,
    get_user_details_repository,
)
from backend.users.use_gateway import UserGateway, get_user_gateway


class UserDetailsService:
    def __init__(
        self,
        user_details_repository: UserDetailsRepository = Depends(
            get_user_details_repository
        ),
        user_gateway: UserGateway = Depends(get_user_gateway),
        user_details_validators: UserDetailsValidationService = Depends(
            get_user_details_validators
        ),
    ):
        self.user_details_repository = user_details_repository
        self.user_gateway = user_gateway
        self.user_details_validators = user_details_validators

    async def get_user_details_by_user_id(
        self, token_payload: dict, user_id_from_request: int
    ):
        user_id_from_token = token_payload["id"]
        self.user_gateway.check_user_permission(
            user_id_from_token, user_id_from_request
        )
        await self.user_gateway.ensure_user_exists_by_id(user_id_from_token)
        await self.user_details_validators.ensure_user_details_exist_by_user_id(
            user_id_from_token
        )
        return await self.user_details_repository.get_user_details_by_user_id(
            user_id_from_token
        )

    async def add_user_details(
        self,
        token_payload: dict,
        user_details_data: UserDetailsCreate,
        user_id_from_request: int,
    ):
        user_id_from_token = token_payload["id"]
        self.user_gateway.check_user_permission(
            user_id_from_token, user_id_from_request
        )
        await self.user_gateway.ensure_user_exists_by_id(user_id_from_token)

        user_details_data.user_id = user_id_from_token

        try:
            await self.get_user_details_by_user_id(token_payload, user_id_from_request)
            return await self.update_user_details(
                token_payload,
                UserDetailsUpdate.map(user_details_data),
                user_id_from_request,
            )
        except HTTPException:
            return await self.user_details_repository.add_user_details(
                user_details_data
            )

    async def update_user_details(
        self,
        token_payload: dict,
        user_details_data: UserDetailsUpdate,
        user_id_from_request: int,
    ):
        user_id_from_token = token_payload["id"]
        self.user_gateway.check_user_permission(
            user_id_from_token, user_id_from_request
        )
        await self.user_gateway.ensure_user_exists_by_id(user_id_from_token)
        await self.get_user_details_by_user_id(token_payload, user_id_from_request)

        return await self.user_details_repository.update_user_details(
            user_id_from_token, user_details_data
        )
