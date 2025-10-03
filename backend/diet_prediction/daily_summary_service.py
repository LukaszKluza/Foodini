from datetime import date
from typing import Optional

from backend.diet_prediction.daily_summary_repository import DailySummaryRepository
from backend.models.user_daily_summary_model import UserDailySummary, UserDailyMealItem


class DailySummaryService:
    def __init__(self, meals_repo: DailySummaryRepository):
        self.meals_repo = meals_repo

    async def get_summary(self, user_id: int, day: date) -> Optional[UserDailySummary]:
        return await self.meals_repo.get_daily_summary(user_id, day)

    async def get_next_meal(self, user_id: int, day: date) -> Optional[UserDailyMealItem]:
        return await self.meals_repo.get_next_meal(user_id, day)

    async def update_meal_status(
        self, daily_summary_id: int, eaten_meal_id: int
    ) -> Optional[UserDailySummary]:
        return await self.meals_repo.update_daily_summary(daily_summary_id, eaten_meal_id)
