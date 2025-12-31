from uuid import UUID

from sqlmodel.ext.asyncio.session import AsyncSession

from backend.daily_summary.enums.meal_status import MealStatus
from backend.models.meal_type_daily_summary import MealTypeDailySummary


class MealTypeDailySummaryRepository:
    def __init__(self, db: AsyncSession):
        self.db = db

    async def get_meal_type_daily_summary(self, meal_type_daily_summary_id: UUID) -> MealTypeDailySummary | None:
        return await self.db.get(MealTypeDailySummary, meal_type_daily_summary_id)

    async def update_meal_type_status(
        self, meal_type_daily_summary_id: UUID, new_status: MealStatus
    ) -> MealTypeDailySummary | None:
        meal_type_daily_summary = await self.get_meal_type_daily_summary(meal_type_daily_summary_id)
        if meal_type_daily_summary:
            meal_type_daily_summary.status = new_status

            await self.db.commit()
            await self.db.refresh(meal_type_daily_summary)
            return meal_type_daily_summary
        return None
