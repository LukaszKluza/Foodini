from datetime import date
from uuid import UUID

from fastapi import APIRouter, Depends, status

from backend.daily_summary.daily_summary_service import DailySummaryService
from backend.daily_summary.dependencies import get_daily_summary_service
from backend.daily_summary.schemas import (
    DailyMacrosSummaryCreate,
    DailyMealsCreate,
)
from backend.meals.schemas import MealCreate
from backend.users.user_gateway import UserGateway, get_user_gateway

admin_daily_summary_router = APIRouter(prefix="/v1/admin/daily-summary")


@admin_daily_summary_router.get(
    "/meals/{day}",
    response_model=DailyMealsCreate,
    summary="Get daily meals",
    description="Retrieves all meals for the specified day for the current user.",
)
async def get_daily_meals(
    day: date,
    diet_service: DailySummaryService = Depends(get_daily_summary_service),
    user_gateway: UserGateway = Depends(get_user_gateway),
):
    user, _ = await user_gateway.get_current_user()
    return await diet_service.get_daily_meals(user, day)


@admin_daily_summary_router.post(
    "/meals",
    status_code=status.HTTP_201_CREATED,
    summary="Add daily meals",
    description="Creates a new daily meals record for the current user.",
)
async def add_daily_meals(
    daily_summary: DailyMealsCreate,
    daily_summary_service: DailySummaryService = Depends(get_daily_summary_service),
    user_gateway: UserGateway = Depends(get_user_gateway),
):
    user, _ = await user_gateway.get_current_user()
    return await daily_summary_service.add_daily_meals(daily_summary, user.id)


@admin_daily_summary_router.get(
    "/macros/{day}",
    response_model=DailyMacrosSummaryCreate,
    summary="Get daily macros summary",
    description="Retrieves the macronutrient summary for the specified day for the current user.",
)
async def get_daily_macros_summary(
    day: date,
    diet_service: DailySummaryService = Depends(get_daily_summary_service),
    user_gateway: UserGateway = Depends(get_user_gateway),
):
    user, _ = await user_gateway.get_current_user()
    return await diet_service.get_daily_macros_summary(user.id, day)


@admin_daily_summary_router.post(
    "/macros",
    status_code=status.HTTP_201_CREATED,
    response_model=DailyMacrosSummaryCreate,
    summary="Add daily macros summary",
    description="Creates a new daily macronutrient summary record for the current user.",
)
async def add_daily_macros_summary(
    daily_summary: DailyMacrosSummaryCreate,
    daily_summary_service: DailySummaryService = Depends(get_daily_summary_service),
    user_gateway: UserGateway = Depends(get_user_gateway),
):
    user, _ = await user_gateway.get_current_user()
    return await daily_summary_service.add_daily_macros_summary(user.id, daily_summary)


@admin_daily_summary_router.get(
    "/meal/{meal_id}",
    response_model=MealCreate,
    summary="Get meal details",
    description="Retrieves detailed information about a specific meal by its ID.",
)
async def get_meal_details(
    meal_id: UUID,
    daily_summary_service: DailySummaryService = Depends(get_daily_summary_service),
    user_gateway: UserGateway = Depends(get_user_gateway),
):
    user, _ = await user_gateway.get_current_user()
    return await daily_summary_service.get_meal_details(meal_id)
