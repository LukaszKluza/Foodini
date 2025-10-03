from fastapi import APIRouter, Depends, status
from datetime import date

from backend.diet_prediction.daily_summary_service import DailySummaryService
from backend.diet_prediction.dependencies import get_daily_summary_service
from backend.users.user_gateway import UserGateway, get_user_gateway
from backend.diet_prediction.schemas import (
    DailySummaryResponse,
    DailySummaryUpdateRequest,
    MealResponse,
)

daily_summary_router = APIRouter(prefix="/v1/daily_summary")


@daily_summary_router.get("/", response_model=DailySummaryResponse)
async def get_daily_summary(
    day: date,
    diet_service: DailySummaryService = Depends(get_daily_summary_service),
    user_gateway: UserGateway = Depends(get_user_gateway),
):
    user, _ = await user_gateway.get_current_user()
    return await diet_service.get_summary(user.id, day)


@daily_summary_router.get("/next_meal", response_model=MealResponse | None)
async def get_next_meal(
    day: date,
    diet_service: DailySummaryService = Depends(get_daily_summary_service),
    user_gateway: UserGateway = Depends(get_user_gateway),
):
    user, _ = await user_gateway.get_current_user()
    return await diet_service.get_next_meal(user.id, day)


@daily_summary_router.patch(
    "/{daily_summary_id}",
    response_model=DailySummaryResponse,
    status_code=status.HTTP_200_OK,
)
async def update_daily_summary(
    daily_summary_id: int,
    body: DailySummaryUpdateRequest,
    diet_service: DailySummaryService = Depends(get_daily_summary_service),
    user_gateway: UserGateway = Depends(get_user_gateway),
):
    user, _ = await user_gateway.get_current_user()
    return await diet_service.update_meal_status(
        daily_summary_id=daily_summary_id,
        eaten_meal_id=body.eaten_meal_id,
    )
