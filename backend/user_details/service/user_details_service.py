from fastapi import HTTPException, status
from fastapi.params import Depends

from backend.user_details.schemas import UserDetailsCreate, UserDetailsUpdate
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
    ):
        self.user_details_repository = user_details_repository
        self.user_gateway = user_gateway

    async def get_user_details_by_user_id(self, token_payload: dict):
        user_id_from_token = token_payload["id"]
        await self.user_gateway.ensure_user_exists_by_id(user_id_from_token)

        return await self.user_details_repository.get_user_details_by_id(
            user_id_from_token
        )

    async def add_user_details(
        self, token_payload: dict, user_details_data: UserDetailsCreate
    ):
        user_id_from_token = token_payload["id"]
        await self.user_gateway.ensure_user_exists_by_id(user_id_from_token)

        user_details_data.user_id = user_id_from_token

        if await self.get_user_details_by_user_id(token_payload):
            return await self.update_user_details(
                token_payload, UserDetailsUpdate.map(user_details_data)
            )

        return await self.user_details_repository.add_user_details(user_details_data)

    async def update_user_details(
        self, token_payload: dict, user_details_data: UserDetailsUpdate
    ):
        user_id_from_token = token_payload["id"]
        await self.user_gateway.ensure_user_exists_by_id(user_id_from_token)

        if await self.get_user_details_by_user_id(token_payload) is None:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="User details do not exist",
            )
        return await self.user_details_repository.update_user_details(
            user_id_from_token, user_details_data
        )
