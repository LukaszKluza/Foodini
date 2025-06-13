from fastapi import Depends, HTTPException, status

from backend.models import UserDetails
from backend.user_details.user_details_repository import (
    UserDetailsRepository,
    get_user_details_repository,
)


class UserDetailsValidationService:
    def __init__(
        self,
        user_details_repository: UserDetailsRepository = Depends(get_user_details_repository),
    ):
        self.user_details_repository = user_details_repository

    async def ensure_user_details_exist_by_user_id(self, user_id: int) -> UserDetails:
        user_details = await self.user_details_repository.get_user_details_by_user_id(user_id)
        if not user_details:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="User details not found",
            )
        return user_details


def get_user_details_validators(
    user_details_repository: UserDetailsRepository = Depends(get_user_details_repository),
) -> UserDetailsValidationService:
    return UserDetailsValidationService(user_details_repository)
