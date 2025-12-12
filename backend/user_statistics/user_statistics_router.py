from fastapi import APIRouter, Depends

from backend.user_statistics.dependancies import get_user_statistics_service
from backend.user_statistics.schemas import UserStatisticsSchema
from backend.user_statistics.user_statistics_service import UserStatisticsService
from backend.users.user_gateway import UserGateway, get_user_gateway

user_statistics_router = APIRouter(prefix="/v1/user-statistics")


@user_statistics_router.get(
    "/",
    response_model=UserStatisticsSchema,
    summary="Get user weekly statistics",
    description="Retrieves weekly nutrition and meal statistics for the currently authenticated user.",
)
async def get_user_weekly_statistics(
    user_statistics_service: UserStatisticsService = Depends(get_user_statistics_service),
    user_gateway: UserGateway = Depends(get_user_gateway),
):
    user, _ = await user_gateway.get_current_user()
    return await user_statistics_service.get_user_weekly_statistics(user)
