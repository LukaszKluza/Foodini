from fastapi import Depends

from backend.daily_summary.daily_summary_gateway import DailySummaryGateway, get_daily_summary_gateway
from backend.user_details.user_details_gateway import UserDetailsGateway, get_user_details_gateway
from backend.user_statistics.user_statistics_service import UserStatisticsService


async def get_user_statistics_service(
    daily_summary_gateway: DailySummaryGateway = Depends(get_daily_summary_gateway),
    user_details_gateway: UserDetailsGateway = Depends(get_user_details_gateway),
) -> UserStatisticsService:
    return UserStatisticsService(daily_summary_gateway, user_details_gateway)
