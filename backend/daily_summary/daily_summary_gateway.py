from datetime import date
from typing import List

from fastapi import Depends

from backend.daily_summary.daily_summary_service import DailySummaryService
from backend.daily_summary.dependencies import get_daily_summary_service
from backend.daily_summary.schemas import DailyMealsCreate, DailyMacrosSummaryCreate
from backend.models import DailyMeals, DailyMacrosSummary


class DailySummaryGateway:
    def __init__(
        self, daily_summary_service: DailySummaryService
    ):
        self.daily_summary_service = daily_summary_service

    async def add_daily_meals(self, daily_meals_data: DailyMealsCreate, user_id: int) -> DailyMeals:
        return await self.daily_summary_service.add_daily_meals(daily_meals_data, user_id)

    async def add_daily_macros_summary(self, data: DailyMacrosSummaryCreate, user_id: int) -> DailyMacrosSummary:
        return await self.daily_summary_service.add_daily_macros_summary(user_id, data)

    async def get_user_latest_meal_names(self, user_id: int, day: date) -> List[str]:
        return await self.daily_summary_service.get_user_latest_meal_names(user_id, day)


def get_daily_summary_gateway(
    daily_summary_service: DailySummaryService = Depends(get_daily_summary_service),
) -> DailySummaryGateway:
    return DailySummaryGateway(daily_summary_service)
