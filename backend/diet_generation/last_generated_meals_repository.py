from datetime import date
from typing import List

from sqlalchemy import UUID, select
from sqlmodel.ext.asyncio.session import AsyncSession

from backend.models import Meal, MealRecipe
from backend.models.user_daily_summary_model import DailyMealsSummary, MealToDailySummary


class LastGeneratedMealsRepository:
    def __init__(self, db: AsyncSession):
        self.db = db

    async def get_last_generated_meals(self, user_id: UUID, from_date: date, to_date: date) -> List[str]:
        dms = DailyMealsSummary
        mt = MealToDailySummary
        m = Meal
        mr = MealRecipe

        query = (
            select(mr.meal_name)
            .select_from(dms)
            .join(mt, mt.daily_summary_id == dms.id)
            .join(m, m.id == mt.meal_id)
            .join(mr, mr.meal_id == m.id)
            .where(
                dms.user_id == user_id,
                dms.day >= from_date,
                dms.day <= to_date
            )
            .distinct()
        )

        result = await self.db.execute(query)
        return result.scalars().all()

    async def get_last_generated_meals1(self, user_id: UUID, from_date: date, to_date: date) -> List[str]:
        dms = DailyMealsSummary
        mt = MealToDailySummary
        mr = MealRecipe

        query = (
            select(mr.meal_name)
            .select_from(dms)
            .join(mt, mt.daily_summary_id == dms.id)
            .join(mr, mr.meal_id == mt.meal_id)
            .where(
                dms.user_id == user_id,
                dms.day >= from_date,
                dms.day <= to_date
            )
            .distinct()
        )

        result = await self.db.execute(query)
        return result.scalars().all()
