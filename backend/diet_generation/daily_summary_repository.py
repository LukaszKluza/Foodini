from datetime import date

from sqlalchemy import select, update
from sqlmodel.ext.asyncio.session import AsyncSession

from backend.diet_generation.schemas import (
    DailyMacrosSummaryCreate,
    DailyMealsCreate,
)
from backend.models.user_daily_summary_model import DailyMacrosSummary, DailyMeals


class DailySummaryRepository:
    def __init__(self, db: AsyncSession):
        self.db = db

    async def add_daily_meals(self, daily_meals_data: DailyMealsCreate, user_id: int) -> DailyMeals:
        user_daily_meals = DailyMeals(user_id=user_id, **daily_meals_data.model_dump())

        self.db.add(user_daily_meals)
        await self.db.commit()
        await self.db.refresh(user_daily_meals)
        return user_daily_meals

    async def get_daily_meals(self, user_id: int, day: date) -> DailyMeals | None:
        query = select(DailyMeals).where(DailyMeals.user_id == user_id, DailyMeals.day == day)
        result = await self.db.execute(query)
        return result.scalar_one_or_none()

    async def update_daily_meals(
        self, user_id: int, daily_meals_data: DailyMealsCreate, day: date
    ) -> DailyMeals | None:
        user_daily_meals = await self.get_daily_meals(user_id, day)
        if user_daily_meals:
            await self.db.execute(
                update(DailyMeals)
                .where(DailyMeals.user_id == user_id, DailyMeals.day == day)
                .values(**daily_meals_data.model_dump())
            )
            await self.db.commit()
            await self.db.refresh(user_daily_meals)
            return user_daily_meals
        return None

    async def add_daily_macros_summary(
        self, daily_summary_data: DailyMacrosSummaryCreate, user_id: int
    ) -> DailyMacrosSummary:
        user_daily_macros_summary = DailyMacrosSummary(user_id=user_id, **daily_summary_data.model_dump())

        self.db.add(user_daily_macros_summary)
        await self.db.commit()
        await self.db.refresh(user_daily_macros_summary)
        return user_daily_macros_summary

    async def get_daily_macros_summary(self, user_id: int, day: date) -> DailyMacrosSummary | None:
        query = select(DailyMacrosSummary).where(DailyMacrosSummary.user_id == user_id, DailyMacrosSummary.day == day)
        result = await self.db.execute(query)
        return result.scalar_one_or_none()

    # Temporary not used
    async def update_daily_macros_summary(
        self, user_id: int, daily_summary_data: DailyMacrosSummaryCreate, day: date
    ) -> DailyMacrosSummary | None:
        user_daily_macros = await self.get_daily_macros_summary(user_id, day)
        if user_daily_macros:
            await self.db.execute(
                update(DailyMacrosSummary)
                .where(DailyMacrosSummary.user_id == user_id, DailyMacrosSummary.day == day)
                .values(**daily_summary_data.model_dump())
            )
            await self.db.commit()
            await self.db.refresh(user_daily_macros)
            return user_daily_macros
        return None

    async def update_meal_status(self, user_id: int, day: date, meals: dict) -> DailyMeals | None:
        user_daily_meals = await self.get_daily_meals(user_id, day)
        if user_daily_meals:
            await self.db.execute(
                update(DailyMeals).where(DailyMeals.user_id == user_id, DailyMeals.day == day).values(meals=meals)
            )
            await self.db.commit()
            await self.db.refresh(user_daily_meals)
            return user_daily_meals
        return None

    async def add_custom_meal(self, user_id: int, day: date, meals: dict) -> DailyMeals | None:
        user_daily_meals = await self.get_daily_meals(user_id, day)

        if user_daily_meals:
            await self.db.execute(
                update(DailyMeals).where(DailyMeals.user_id == user_id, DailyMeals.day == day).values(meals=meals)
            )
            await self.db.commit()
            await self.db.refresh(user_daily_meals)
            return user_daily_meals
        return None
