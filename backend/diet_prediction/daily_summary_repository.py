from datetime import date

from sqlalchemy import select, update
from sqlmodel.ext.asyncio.session import AsyncSession

from backend.diet_prediction.schemas import DailyMacrosSummaryCreate, DailyMealsCreate, MealInfoUpdateRequest
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

    async def add_daily_macros_summary(
        self, daily_summary_data: DailyMacrosSummaryCreate, user_id: int
    ) -> DailyMacrosSummary:
        user_daily_macros_summary = DailyMacrosSummary(user_id=user_id, **daily_summary_data.model_dump())

        self.db.add(user_daily_macros_summary)
        await self.db.commit()
        await self.db.refresh(user_daily_macros_summary)
        return user_daily_macros_summary

    async def get_daily_macros_summary(self, user_id: int, day: date) -> DailyMacrosSummary | None:
        query = select(DailyMacrosSummary).where(DailyMeals.user_id == user_id, DailyMeals.day == day)
        result = await self.db.execute(query)
        return result.scalar_one_or_none()

    async def update_daily_macros_summary(
        self, user_id: int, daily_summary_data: DailyMacrosSummaryCreate
    ) -> DailyMacrosSummary | None:
        daily_macros_summary = await self.get_daily_macros_summary(user_id, daily_summary_data.day)
        if daily_macros_summary:
            daily_macros_summary_request = DailyMacrosSummary(id=user_id, **daily_summary_data.model_dump())
            updated_daily_macros_summary = await self.db.merge(daily_macros_summary_request)
            await self.db.commit()
            await self.db.refresh(updated_daily_macros_summary)
            return updated_daily_macros_summary
        return None

    async def update_meal_status(self, user_id: int, update_meal_data: MealInfoUpdateRequest) -> DailyMeals | None:
        day = update_meal_data.day
        meal_type = update_meal_data.meal_type.value
        status = update_meal_data.status.value
        user_daily_meals = await self.get_daily_meals(user_id, day)
        if not user_daily_meals:
            return None

        meals = user_daily_meals.meals or {}

        if meal_type not in meals:
            return None

        meals[meal_type]["status"] = status
        user_daily_meals.meals = meals

        # return user_daily_meals

        await self.db.execute(
            update(DailyMeals).where(DailyMeals.user_id == user_id, DailyMeals.day == day).values(meals=meals)
        )
        await self.db.commit()
        await self.db.refresh(user_daily_meals)
        return user_daily_meals
