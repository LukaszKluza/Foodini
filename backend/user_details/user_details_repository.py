from datetime import date, datetime
from uuid import UUID

from sqlalchemy import select
from sqlmodel.ext.asyncio.session import AsyncSession

from backend.models import UserDetails, UserWeightHistory
from backend.user_details.schemas import UserDetailsCreate, UserDetailsUpdate


class UserDetailsRepository:
    def __init__(self, db: AsyncSession):
        self.db = db

    async def add_user_details(self, user_details_data: UserDetailsCreate, user_id: UUID) -> UserDetails:
        user_details = UserDetails(user_id=user_id, **user_details_data.model_dump())
        self.db.add(user_details)
        await self.db.commit()
        await self.db.refresh(user_details)
        return user_details

    async def get_user_details_by_id(self, user_details_id: UUID) -> UserDetails | None:
        return await self.db.get(UserDetails, user_details_id)

    async def get_user_details_by_user_id(self, user_id: UUID) -> UserDetails:
        query = select(UserDetails).where(UserDetails.user_id == user_id)
        result = await self.db.execute(query)
        return result.scalar_one_or_none()

    async def get_date_of_last_update_user_details(self, user_id: UUID) -> datetime:
        query = select(UserDetails.updated_at).where(UserDetails.user_id == user_id)
        result = await self.db.execute(query)
        return result.scalar_one_or_none()

    async def update_user_details_by_user_id(
        self, user_id: UUID, user_details_data: UserDetailsUpdate
    ) -> UserDetails | None:
        user_details = await self.get_user_details_by_user_id(user_id)
        if user_details:
            user_details_request = UserDetails(id=user_details.id, **user_details_data.model_dump(exclude_unset=True))
            updated_user_details = await self.db.merge(user_details_request)
            await self.db.commit()
            await self.db.refresh(updated_user_details)
            return updated_user_details
        return None

    async def add_user_weight(self, entry: UserWeightHistory) -> UserWeightHistory:
        self.db.add(entry)
        await self.db.commit()
        await self.db.refresh(entry)
        return entry

    async def get_user_weight_history_by_user_id_and_day(self, user_id: UUID, day: date) -> UserWeightHistory | None:
        query = select(UserWeightHistory).where(
            UserWeightHistory.user_id == user_id,
            UserWeightHistory.day == day,
        )
        result = await self.db.execute(query)
        return result.scalar_one_or_none()

    async def get_user_weight_history_by_user_id_and_date_range(
        self, user_id: UUID, start_date: date, end_date: date
    ) -> list[UserWeightHistory]:
        query = (
            select(UserWeightHistory)
            .where(
                UserWeightHistory.user_id == user_id,
                UserWeightHistory.day >= start_date,
                UserWeightHistory.day <= end_date,
            )
            .order_by(UserWeightHistory.day.desc())
        )
        result = await self.db.execute(query)
        return list(result.scalars().all())
