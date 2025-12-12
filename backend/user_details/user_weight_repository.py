from datetime import date
from uuid import UUID

from sqlalchemy import select
from sqlmodel.ext.asyncio.session import AsyncSession

from backend.models import UserWeightHistory


class UserWeightRepository:
    def __init__(self, db: AsyncSession):
        self.db = db

    async def add_user_weight(self, entry: UserWeightHistory) -> UserWeightHistory:
        existing = await self.get_user_weight_history_by_user_id_and_day(user_id=entry.user_id, day=entry.day)

        if existing:
            existing.weight_kg = entry.weight_kg
            await self.db.commit()
            await self.db.refresh(existing)
            return existing
        else:
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
