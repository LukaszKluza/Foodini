from datetime import date

from fastapi import APIRouter, Depends, status

from backend.diet_generation.daily_summary_service import DailySummaryService
from backend.diet_generation.dependencies import get_daily_summary_service
from backend.diet_generation.schemas import (
    CustomMealUpdateRequest,
    DailyMacrosSummaryCreate,
    DailyMealsCreate,
    MealInfoUpdateRequest,
)
from backend.users.user_gateway import UserGateway, get_user_gateway

daily_summary_router = APIRouter(prefix="/v1/daily_summary")


@daily_summary_router.get("/meals/{day}", response_model=DailyMealsCreate)
async def get_daily_meals(
    day: date,
    diet_service: DailySummaryService = Depends(get_daily_summary_service),
    user_gateway: UserGateway = Depends(get_user_gateway),
):
    user, _ = await user_gateway.get_current_user()
    return await diet_service.get_daily_meals(user.id, day)


@daily_summary_router.post("/meals", status_code=status.HTTP_201_CREATED, response_model=DailyMealsCreate)
async def add_daily_meals(
    daily_summary: DailyMealsCreate,
    daily_summary_service: DailySummaryService = Depends(get_daily_summary_service),
    user_gateway: UserGateway = Depends(get_user_gateway),
):
    user, _ = await user_gateway.get_current_user()
    return await daily_summary_service.add_daily_meals(daily_summary, user.id)


@daily_summary_router.get("/macros/{day}", response_model=DailyMacrosSummaryCreate)
async def get_daily_macros_summary(
    day: date,
    diet_service: DailySummaryService = Depends(get_daily_summary_service),
    user_gateway: UserGateway = Depends(get_user_gateway),
):
    user, _ = await user_gateway.get_current_user()
    return await diet_service.get_daily_macros_summary(user.id, day)


@daily_summary_router.post("/macros", status_code=status.HTTP_201_CREATED, response_model=DailyMacrosSummaryCreate)
async def add_daily_macros_summary(
    daily_summary: DailyMacrosSummaryCreate,
    daily_summary_service: DailySummaryService = Depends(get_daily_summary_service),
    user_gateway: UserGateway = Depends(get_user_gateway),
):
    user, _ = await user_gateway.get_current_user()
    return await daily_summary_service.add_daily_macros_summary(user.id, daily_summary)


@daily_summary_router.patch("/macros", response_model=DailyMacrosSummaryCreate)
async def update_daily_macros_summary(
    daily_summary: DailyMacrosSummaryCreate,
    daily_summary_service: DailySummaryService = Depends(get_daily_summary_service),
    user_gateway: UserGateway = Depends(get_user_gateway),
):
    user, _ = await user_gateway.get_current_user()
    return await daily_summary_service.update_daily_macros_summary(user.id, daily_summary)


@daily_summary_router.patch("/meals", response_model=DailyMealsCreate)
async def update_meal_status(
    meal_info_update: MealInfoUpdateRequest,
    daily_summary_service: DailySummaryService = Depends(get_daily_summary_service),
    user_gateway: UserGateway = Depends(get_user_gateway),
):
    user, _ = await user_gateway.get_current_user()
    return await daily_summary_service.update_meal_status(user.id, meal_info_update)


@daily_summary_router.patch("/meals/custom", response_model=DailyMealsCreate)
async def add_custom_meal(
    custom_meal: CustomMealUpdateRequest,
    daily_summary_service: DailySummaryService = Depends(get_daily_summary_service),
    user_gateway: UserGateway = Depends(get_user_gateway),
):
    user, _ = await user_gateway.get_current_user()
    return await daily_summary_service.add_custom_meal(user.id, custom_meal)
