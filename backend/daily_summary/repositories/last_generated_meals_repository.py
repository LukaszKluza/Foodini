from datetime import date
from typing import List

from sqlalchemy import UUID, select
from sqlmodel.ext.asyncio.session import AsyncSession

from backend.models import MealRecipe
from backend.models.composed_meal_item_model import ComposedMealItem
from backend.models.daily_summary_model import DailySummary
from backend.models.meal_type_daily_summary import MealTypeDailySummary


class LastGeneratedMealsRepository:
    def __init__(self, db: AsyncSession):
        self.db = db

    async def get_last_generated_meals(self, user_id: UUID, from_date: date, to_date: date) -> List[str]:
        dms = DailySummary
        mds = MealTypeDailySummary
        mr = MealRecipe
        cmi = ComposedMealItem

        query = (
            select(mr.meal_name)
            .join(cmi, cmi.meal_id == mr.meal_id)
            .join(mds, mds.id == cmi.meal_type_daily_summary_id)
            .join(dms, dms.id == mds.daily_summary_id)
            .where(dms.user_id == user_id, dms.day >= from_date, dms.day <= to_date)
            .distinct()
        )

        result = await self.db.execute(query)
        return result.scalars().all()
