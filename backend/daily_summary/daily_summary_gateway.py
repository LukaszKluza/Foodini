from datetime import date
from typing import List
from uuid import UUID

from fastapi import Depends

from backend.daily_summary.daily_summary_service import DailySummaryService
from backend.daily_summary.dependencies import get_daily_summary_service
from backend.daily_summary.schemas import DailyMacrosSummaryCreate, DailyMealsCreate


class DailySummaryGateway:
    def __init__(self, daily_summary_service: DailySummaryService):
        self.daily_summary_service = daily_summary_service

    async def get_last_generated_meals(self, user_id: UUID, from_date: date, to_date: date) -> List[str]:
        return await self.daily_summary_service.get_last_generated_meals(user_id, from_date, to_date)

    async def get_daily_meals(self, user_id: UUID, day: date):
        return await self.daily_summary_service.get_daily_meals(user_id, day)

    async def add_daily_meals(self, daily_meals_data: DailyMealsCreate, user_id: UUID):
        await self.daily_summary_service.add_daily_meals(daily_meals_data, user_id)

    async def add_daily_macros_summary(self, user_id: UUID, data: DailyMacrosSummaryCreate):
        await self.daily_summary_service.add_daily_macros_summary(user_id, data)

    async def get_daily_macros_summary(self, user_id: UUID, day: date):
        return await self.daily_summary_service.get_daily_macros_summary(user_id, day)


def get_daily_summary_gateway(
    daily_summary_service: DailySummaryService = Depends(get_daily_summary_service),
) -> DailySummaryGateway:
    return DailySummaryGateway(daily_summary_service)
