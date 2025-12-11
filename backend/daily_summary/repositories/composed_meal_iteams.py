from uuid import UUID

from sqlalchemy import select
from sqlalchemy.orm import selectinload
from sqlmodel.ext.asyncio.session import AsyncSession

from backend.models.composed_meal_item import ComposedMealItem
from backend.models.meals_daily_summary import MealDailySummary
from backend.models.user_daily_summary_model import DailyMealsSummary


class ComposedMealItemsRepository:
    def __init__(self, db: AsyncSession):
        self.db = db

    async def get_composed_meal_item_by_user_id_and_meal_id(self, user_id: UUID, meal_id: UUID) -> ComposedMealItem:
        query = (
            select(ComposedMealItem)
            .options(selectinload(ComposedMealItem.daily_meal).selectinload(MealDailySummary.daily_summary))
            .where(
                ComposedMealItem.meal_id == meal_id,
                ComposedMealItem.daily_meal.has(
                    MealDailySummary.daily_summary.has(DailyMealsSummary.user_id == user_id)
                ),
            )
        )

        result = await self.db.execute(query)
        return result.scalar_one_or_none()
