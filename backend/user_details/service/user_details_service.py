from typing import Type

from fastapi import HTTPException

from backend.core.not_found_in_database_exception import NotFoundInDatabaseException
from backend.models import User
from backend.user_details.enums import DietType
from backend.user_details.schemas import UserDetailsCreate, UserDetailsUpdate
from backend.user_details.service.user_details_validation_service import (
    UserDetailsValidationService,
)
from backend.user_details.user_details_repository import UserDetailsRepository
from backend.users.user_gateway import UserGateway


class UserDetailsService:
    def __init__(
        self,
        user_details_repository: UserDetailsRepository,
        user_gateway: UserGateway,
        user_details_validators: UserDetailsValidationService,
    ):
        self.user_details_repository = user_details_repository
        self.user_gateway = user_gateway
        self.user_details_validators = user_details_validators

    async def get_user_details_by_user(self, user: Type[User]):
        return await self.user_details_validators.ensure_user_details_exist_by_user_id(user.id)

    async def get_date_of_last_update_user_details(self, user: Type[User]):
        last_update = await self.user_details_repository.get_date_of_last_update_user_details(user.id)
        if not last_update:
            raise NotFoundInDatabaseException("No date in database of last user details update.")
        return last_update

    async def add_user_details(
        self,
        user_details_data: UserDetailsCreate,
        user: Type[User],
    ):
        if user_details_data.diet_type == DietType.WEIGHT_MAINTENANCE:
            user_details_data.diet_goal_kg = user_details_data.weight_kg

        try:
            await self.get_user_details_by_user(user)
            return await self.update_user_details(
                UserDetailsUpdate.map(user_details_data),
                user,
            )
        except (HTTPException, NotFoundInDatabaseException):
            return await self.user_details_repository.add_user_details(user_details_data, user.id)

    async def update_user_details(
        self,
        user_details_data: UserDetailsUpdate,
        user: Type[User],
    ):
        await self.get_user_details_by_user(user)

        return await self.user_details_repository.update_user_details_by_user_id(user.id, user_details_data)
