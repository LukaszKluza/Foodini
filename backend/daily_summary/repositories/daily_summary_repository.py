from datetime import date
from uuid import UUID

from sqlalchemy import delete, select, update
from sqlalchemy.orm import selectinload
from sqlmodel.ext.asyncio.session import AsyncSession

from backend.daily_summary.enums.meal_status import MealStatus
from backend.daily_summary.schemas import DailyMacrosSummaryCreate, DailyMealsCreate
from backend.models.user_daily_summary_model import DailyMacrosSummary, DailyMealsSummary, MealDailySummary


class DailySummaryRepository:
    def __init__(self, db: AsyncSession):
        self.db = db

    async def add_daily_meals_summary(self, daily_meals_data: DailyMealsCreate, user_id: UUID) -> DailyMealsSummary:
        user_daily_meals = DailyMealsSummary(user_id=user_id, **daily_meals_data.model_dump(exclude={"meals"}))

        self.db.add(user_daily_meals)
        await self.db.flush()

        for meal_info in daily_meals_data.meals.values():
            if meal_info.meal_id is not None:
                link = MealDailySummary(
                    meal_id=meal_info.meal_id,
                    daily_summary_id=user_daily_meals.id,
                    status=meal_info.status,
                )
                self.db.add(link)

        await self.db.commit()
        await self.db.refresh(user_daily_meals)
        return user_daily_meals

    async def get_daily_meals_summary(self, user_id: UUID, day: date) -> DailyMealsSummary | None:
        query = (
            select(DailyMealsSummary)
            .where(DailyMealsSummary.user_id == user_id, DailyMealsSummary.day == day)
            .options(selectinload(DailyMealsSummary.daily_meals).selectinload(MealDailySummary.meal))
        )
        result = await self.db.execute(query)
        return result.scalar_one_or_none()

    async def update_daily_meals(
        self, user_id: UUID, daily_meals_data: DailyMealsCreate, day: date
    ) -> DailyMealsSummary | None:
        user_daily_meals_summary = await self.get_daily_meals_summary(user_id, day)
        if user_daily_meals_summary:
            await self.db.execute(
                update(DailyMealsSummary)
                .where(DailyMealsSummary.user_id == user_id, DailyMealsSummary.day == day)
                .values(**daily_meals_data.model_dump(exclude={"meals"}))
            )

            await self.db.execute(
                delete(MealDailySummary).where(MealDailySummary.daily_summary_id == user_daily_meals_summary.id)
            )

            for meal_info in daily_meals_data.meals.values():
                if meal_info.meal_id is not None:
                    link = MealDailySummary(
                        meal_id=meal_info.meal_id,
                        daily_summary_id=user_daily_meals_summary.id,
                        status=meal_info.status,
                    )
                    self.db.add(link)
            await self.db.commit()
            await self.db.refresh(user_daily_meals_summary)
            return user_daily_meals_summary
        return None

    async def add_daily_macros_summary(
        self, daily_summary_data: DailyMacrosSummaryCreate, user_id: UUID
    ) -> DailyMacrosSummary:
        user_daily_macros_summary = DailyMacrosSummary(user_id=user_id, **daily_summary_data.model_dump())

        self.db.add(user_daily_macros_summary)
        await self.db.commit()
        await self.db.refresh(user_daily_macros_summary)
        return user_daily_macros_summary

    async def get_daily_macros_summary(self, user_id: UUID, day: date) -> DailyMacrosSummary | None:
        query = select(DailyMacrosSummary).where(DailyMacrosSummary.user_id == user_id, DailyMacrosSummary.day == day)
        result = await self.db.execute(query)
        return result.scalar_one_or_none()

    async def update_daily_macros_summary(
        self, user_id: UUID, daily_summary_data: DailyMacrosSummaryCreate, day: date
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

    async def update_meal_status(
        self, user_id: UUID, day: date, meal_id: UUID, new_status: MealStatus
    ) -> DailyMealsSummary | None:
        user_daily_meals_summary = await self.get_daily_meals_summary(user_id, day)
        if user_daily_meals_summary:
            summary_id = user_daily_meals_summary.id
            await self.db.execute(
                update(MealDailySummary)
                .where(
                    MealDailySummary.daily_summary_id == summary_id,
                    MealDailySummary.meal_id == meal_id,
                )
                .values(status=new_status)
                .execution_options(synchronize_session="fetch")
            )
            await self.db.commit()
            await self.db.refresh(user_daily_meals_summary)
            return user_daily_meals_summary
        return None

    async def add_custom_meal(self, user_id: UUID, day: date, meals: dict) -> DailyMealsSummary | None:
        user_daily_meals_summary = await self.get_daily_meals_summary(user_id, day)

        if user_daily_meals_summary:
            for meal_info in meals.values():
                if meal_info.meal_id is not None:
                    link = MealDailySummary(
                        daily_summary_id=user_daily_meals_summary.id,
                        meal_id=meal_info.meal_id,
                        status=meal_info.status,
                    )
                    self.db.add(link)
            await self.db.commit()
            await self.db.refresh(user_daily_meals_summary)
            return user_daily_meals_summary
        return None
