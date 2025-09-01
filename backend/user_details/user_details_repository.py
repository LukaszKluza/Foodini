from typing import Type

from sqlalchemy import select
from sqlmodel.ext.asyncio.session import AsyncSession
from backend.models import UserDetails
from backend.core.not_found_in_database_exception import NotFoundInDatabaseException
from .schemas import UserDetailsCreate, UserDetailsUpdate


class UserDetailsRepository:
    def __init__(self, db: AsyncSession):
        self.db = db

    async def add_user_details(
        self, user_details_data: UserDetailsCreate, user_id: int
    ) -> UserDetails:
        user_details = UserDetails(user_id=user_id, **user_details_data.model_dump())
        self.db.add(user_details)
        await self.db.commit()
        await self.db.refresh(user_details)
        return user_details

    async def get_user_details_by_id(self, user_details_id: int) -> Type[UserDetails]:
        user_details = await self.db.get(UserDetails, user_details_id)

        if user_details is None:
            raise NotFoundInDatabaseException("Details not found")

        return user_details

    async def get_user_details_by_user_id(self, user_id: int) -> UserDetails:
        query = select(UserDetails).where(UserDetails.user_id == user_id)
        result = await self.db.execute(query)
        user_details = result.scalar_one_or_none()

        if user_details is None:
            raise NotFoundInDatabaseException("Details not found")

        return user_details

    async def update_user_details_by_user_id(
        self, user_id: int, user_details_data: UserDetailsUpdate
    ) -> UserDetails | None:
        user_details = await self.get_user_details_by_user_id(user_id)
        if user_details:
            user_details_request = UserDetails(
                id=user_details.id, **user_details_data.model_dump(exclude_unset=True)
            )
            updated_user_details = await self.db.merge(user_details_request)
            await self.db.commit()
            await self.db.refresh(updated_user_details)
            return updated_user_details
        return None
