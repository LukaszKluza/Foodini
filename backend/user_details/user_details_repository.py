from fastapi.params import Depends
from sqlalchemy import select
from sqlmodel.ext.asyncio.session import AsyncSession
from backend.models import UserDetails
from .schemas import UserDetailsCreate, UserDetailsUpdate
from backend.core.database import get_db


class UserDetailsRepository:
    def __init__(self, db: AsyncSession):
        self.db = db

    async def add_user_details(
        self, user_details_data: UserDetailsCreate
    ) -> UserDetails:
        user_details = UserDetails(**user_details_data.model_dump())
        self.db.add(user_details)
        await self.db.commit()
        await self.db.refresh(user_details)
        return user_details

    async def get_user_details_by_id(self, user_details_id: int) -> UserDetails | None:
        return await self.db.get(UserDetails, user_details_id)

    async def get_user_details_by_user_id(self, user_id: int) -> UserDetails:
        query = select(UserDetails).where(UserDetails.user_id == user_id)
        result = await self.db.execute(query)
        return result.scalar_one_or_none()

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


async def get_user_details_repository(
    db: AsyncSession = Depends(get_db),
) -> UserDetailsRepository:
    return UserDetailsRepository(db)
