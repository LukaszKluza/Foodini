from datetime import date
from uuid import UUID

from fastapi import APIRouter, Depends, status

from backend.daily_summary.daily_summary_service import DailySummaryService
from backend.daily_summary.dependencies import get_daily_summary_service
from backend.daily_summary.schemas import (
    CustomMealUpdateRequest,
    DailyMacrosSummaryCreate,
    DailyMealsCreate,
    DailySummary,
    MealInfo,
    MealInfoUpdateRequest,
    MealMacros,
    RemoveMealRequest,
    RemoveMealResponse,
)
from backend.meals.schemas import MealCreate
from backend.users.user_gateway import UserGateway, get_user_gateway

daily_summary_router = APIRouter(prefix="/v1/daily-summary")


@daily_summary_router.get("/{day}", response_model=DailySummary)
async def get_daily_summary(
    day: date,
    diet_service: DailySummaryService = Depends(get_daily_summary_service),
    user_gateway: UserGateway = Depends(get_user_gateway),
):
    user, _ = await user_gateway.get_current_user()
    return await diet_service.get_daily_summary(user, day)


# DEV
@daily_summary_router.get("/meals/{day}", response_model=DailyMealsCreate)
async def get_daily_meals(
    day: date,
    diet_service: DailySummaryService = Depends(get_daily_summary_service),
    user_gateway: UserGateway = Depends(get_user_gateway),
):
    user, _ = await user_gateway.get_current_user()
    return await diet_service.get_daily_meals(user, day)


# DEV
@daily_summary_router.post("/meals", status_code=status.HTTP_201_CREATED)
async def add_daily_meals(
    daily_summary: DailyMealsCreate,
    daily_summary_service: DailySummaryService = Depends(get_daily_summary_service),
    user_gateway: UserGateway = Depends(get_user_gateway),
):
    user, _ = await user_gateway.get_current_user()
    return await daily_summary_service.add_daily_meals(daily_summary, user.id)


# DEV
@daily_summary_router.get("/macros/{day}", response_model=DailyMacrosSummaryCreate)
async def get_daily_macros_summary(
    day: date,
    diet_service: DailySummaryService = Depends(get_daily_summary_service),
    user_gateway: UserGateway = Depends(get_user_gateway),
):
    user, _ = await user_gateway.get_current_user()
    return await diet_service.get_daily_macros_summary(user.id, day)


# DEV
@daily_summary_router.post("/macros", status_code=status.HTTP_201_CREATED, response_model=DailyMacrosSummaryCreate)
async def add_daily_macros_summary(
    daily_summary: DailyMacrosSummaryCreate,
    daily_summary_service: DailySummaryService = Depends(get_daily_summary_service),
    user_gateway: UserGateway = Depends(get_user_gateway),
):
    user, _ = await user_gateway.get_current_user()
    return await daily_summary_service.add_daily_macros_summary(user.id, daily_summary)


@daily_summary_router.patch("/meals", response_model=MealMacros)
async def update_meal_status(
    meal_info_update: MealInfoUpdateRequest,
    daily_summary_service: DailySummaryService = Depends(get_daily_summary_service),
    user_gateway: UserGateway = Depends(get_user_gateway),
):
    user, _ = await user_gateway.get_current_user()
    return await daily_summary_service.update_meal_status(user, meal_info_update)


@daily_summary_router.patch("/meals/custom", response_model=MealInfo)
async def add_custom_meal(
    custom_meal: CustomMealUpdateRequest,
    daily_summary_service: DailySummaryService = Depends(get_daily_summary_service),
    user_gateway: UserGateway = Depends(get_user_gateway),
):
    user, _ = await user_gateway.get_current_user()
    return await daily_summary_service.add_custom_meal(user, custom_meal)


@daily_summary_router.delete("/meal", response_model=RemoveMealResponse)
async def remove_meal_from_summary(
    meal_to_remove: RemoveMealRequest,
    daily_summary_service: DailySummaryService = Depends(get_daily_summary_service),
    user_gateway: UserGateway = Depends(get_user_gateway),
):
    user, _ = await user_gateway.get_current_user()
    return await daily_summary_service.remove_meal_from_summary(user, meal_to_remove)


# DEV
@daily_summary_router.get("/meal/{meal_id}", response_model=MealCreate)
async def get_meal_details(
    meal_id: UUID,
    daily_summary_service: DailySummaryService = Depends(get_daily_summary_service),
    user_gateway: UserGateway = Depends(get_user_gateway),
):
    user, _ = await user_gateway.get_current_user()
    return await daily_summary_service.get_meal_details(meal_id)
