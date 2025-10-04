from datetime import date
from typing import Optional

from sqlalchemy import select
from sqlalchemy.orm import selectinload
from sqlmodel.ext.asyncio.session import AsyncSession

from backend.diet_prediction.enums.meal_status import MealStatus
from backend.diet_prediction.schemas import UserDailySummaryCreate
from backend.models.user_daily_summary_model import UserDailyMealItem, UserDailySummary


class DailySummaryRepository:
    def __init__(self, db: AsyncSession):
        self.db = db

    async def add_daily_summary(self, daily_summary_data: UserDailySummaryCreate, user_id: int) -> UserDailySummary:
        user_daily_summary = UserDailySummary(user_id=user_id, **daily_summary_data.model_dump(exclude={"meal_items"}))

        user_daily_summary.meal_items = [
            UserDailyMealItem(**item.model_dump()) for item in daily_summary_data.meal_items
        ]

        self.db.add(user_daily_summary)
        await self.db.commit()
        await self.db.refresh(user_daily_summary)

        result = await self.db.execute(
            select(UserDailySummary)
            .options(selectinload(UserDailySummary.meal_items).selectinload(UserDailyMealItem.meal))
            .where(UserDailySummary.id == user_daily_summary.id)
        )
        return result.scalar_one()

    async def get_daily_summary(self, user_id: int, day: date) -> UserDailySummary | None:
        query = (
            select(UserDailySummary)
            .options(selectinload(UserDailySummary.meal_items).selectinload(UserDailyMealItem.meal))
            .where(UserDailySummary.user_id == user_id, UserDailySummary.day == day)
        )
        result = await self.db.execute(query)
        return result.scalar_one_or_none()

    async def get_meals_by_day(self, user_id: int, day: date) -> list[UserDailyMealItem] | None:
        daily_summary = await self.get_daily_summary(user_id, day)
        if daily_summary:
            return daily_summary.meal_items
        return None

    async def get_next_meal(self, user_id: int, day: date) -> UserDailyMealItem | None:
        daily_summary = await self.get_daily_summary(user_id, day)
        if not daily_summary or not daily_summary.next_meal:
            return None
        return await self.db.get(UserDailyMealItem, daily_summary.next_meal)

    async def update_daily_summary(self, daily_summary_id: int, eaten_meal_id: int) -> UserDailySummary | None:
        daily_summary: Optional[UserDailySummary] = await self.db.get(UserDailySummary, daily_summary_id)
        if not daily_summary:
            return None

        sorted_items = sorted(daily_summary.meal_items, key=lambda x: x.meal.meal_type.order)

        for m in sorted_items:
            if eaten_meal_id and m.id == eaten_meal_id:
                m.status = MealStatus.EATEN
                self.db.add(m)
                daily_summary.calories_consumed += m.meal.calories
                daily_summary.protein_consumed += m.meal.protein
                daily_summary.fat_consumed += m.meal.fat
                daily_summary.carbs_consumed += m.meal.carbs
                break
            elif m.status == MealStatus.PENDING:
                m.status = MealStatus.SKIPPED
                self.db.add(m)

        pending_meals = [m for m in sorted_items if m.status == MealStatus.PENDING]
        daily_summary.next_meal = pending_meals[0].id if pending_meals else None

        self.db.add(daily_summary)
        await self.db.commit()
        await self.db.refresh(daily_summary)

        return daily_summary
