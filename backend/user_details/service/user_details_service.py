from fastapi import HTTPException
from fastapi.params import Depends

from backend.models import User, UserDetails
from backend.user_details.schemas import UserDetailsCreate, UserDetailsUpdate
from backend.user_details.service.user_details_validation_service import (
    UserDetailsValidationService,
    get_user_details_validators,
)
from backend.user_details.user_details_repository import (
    UserDetailsRepository,
    get_user_details_repository,
)


class UserDetailsService:
    def __init__(
        self,
        user_details_repository: UserDetailsRepository,
        user_details_validators: UserDetailsValidationService
    ):
        self.user_details_repository = user_details_repository
        self.user_details_validators = user_details_validators

    async def get_user_details_by_user(self, user: User) -> UserDetails:
        await self.user_details_validators.ensure_user_details_exist_by_user_id(user.id)
        return await self.user_details_repository.get_user_details_by_user_id(user.id)

    async def add_user_details(
        self,
        user_details_data: UserDetailsCreate,
        user: User,
    ) -> UserDetails:
        try:
            await self.get_user_details_by_user(user)
            return await self.update_user_details(
                UserDetailsUpdate.map(user_details_data),
                user,
            )
        except HTTPException:
            return await self.user_details_repository.add_user_details(
                user_details_data, user.id
            )

    async def update_user_details(
        self,
        user_details_data: UserDetailsUpdate,
        user: User,
    ) -> UserDetails:
        await self.get_user_details_by_user(user)

        return await self.user_details_repository.update_user_details_by_user_id(
            user.id, user_details_data
        )


def get_user_details_service(
    user_details_repository: UserDetailsRepository = Depends(
        get_user_details_repository
    ),
    user_details_validators: UserDetailsValidationService = Depends(
        get_user_details_validators
    ),
) -> UserDetailsService:
    return UserDetailsService(user_details_repository, user_details_validators)
