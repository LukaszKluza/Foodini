from datetime import date
from typing import List

from fastapi import Depends

from backend.daily_summary.daily_summary_service import DailySummaryService
from backend.daily_summary.dependencies import get_daily_summary_service


class DailySummaryGateway:
    def __init__(self, daily_summary_service: DailySummaryService):
        self.daily_summary_service = daily_summary_service

    async def get_user_latest_meal_names(self, user_id: int, day: date) -> List[str]:
        return await self.daily_summary_service.get_user_latest_meal_names(user_id, day)


def get_daily_summary_gateway(
    daily_summary_service: DailySummaryService = Depends(get_daily_summary_service),
) -> DailySummaryGateway:
    return DailySummaryGateway(daily_summary_service)
