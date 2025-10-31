from uuid import UUID

from backend.core.not_found_in_database_exception import NotFoundInDatabaseException
from backend.models import UserDetails
from backend.user_details.user_details_repository import UserDetailsRepository


class UserDetailsValidationService:
    def __init__(
        self,
        user_details_repository: UserDetailsRepository,
    ):
        self.user_details_repository = user_details_repository

    async def ensure_user_details_exist_by_user_id(self, user_id: UUID) -> UserDetails:
        user_details = await self.user_details_repository.get_user_details_by_user_id(user_id)
        if not user_details:
            raise NotFoundInDatabaseException("User details not found")
        return user_details
