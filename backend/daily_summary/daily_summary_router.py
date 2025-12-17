from datetime import date
from uuid import UUID

from fastapi import APIRouter, Depends, status

from backend.core.role_sets import user_or_admin
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

daily_summary_router = APIRouter(prefix="/v1/daily-summary", tags=["User", "Admin"], dependencies=[user_or_admin])


@daily_summary_router.get(
    "/{day}",
    response_model=DailySummary,
    summary="Get daily summary",
    description="Retrieves the daily summary of meals and nutrition for the specified day for the current user.",
)
async def get_daily_summary(
    day: date,
    diet_service: DailySummaryService = Depends(get_daily_summary_service),
    user_gateway: UserGateway = Depends(get_user_gateway),
):
    user, _ = await user_gateway.get_current_user()
    return await diet_service.get_daily_summary(user, day)


# DEV
@daily_summary_router.get(
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


# DEV
@daily_summary_router.post(
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


# DEV
@daily_summary_router.get(
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


# DEV
@daily_summary_router.post(
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


@daily_summary_router.patch(
    "/meals",
    response_model=MealMacros,
    summary="Update meal status",
    description="Updates the status of a meal (pending, to eat, eaten, skipped) in the daily summary.",
)
async def update_meal_status(
    meal_info_update: MealInfoUpdateRequest,
    daily_summary_service: DailySummaryService = Depends(get_daily_summary_service),
    user_gateway: UserGateway = Depends(get_user_gateway),
):
    user, _ = await user_gateway.get_current_user()
    return await daily_summary_service.update_meal_status(user, meal_info_update)


@daily_summary_router.patch(
    "/meals/custom",
    response_model=MealInfo,
    summary="Add custom meal",
    description="Adds a custom meal created by the user to their proper daily summary.",
)
async def add_custom_meal(
    custom_meal: CustomMealUpdateRequest,
    daily_summary_service: DailySummaryService = Depends(get_daily_summary_service),
    user_gateway: UserGateway = Depends(get_user_gateway),
):
    user, _ = await user_gateway.get_current_user()
    return await daily_summary_service.add_custom_meal(user, custom_meal)


@daily_summary_router.delete(
    "/meal",
    response_model=RemoveMealResponse,
    summary="Remove meal from summary",
    description="Removes a specific meal from the user's daily summary for specified day.",
)
async def remove_meal_from_summary(
    meal_to_remove: RemoveMealRequest,
    daily_summary_service: DailySummaryService = Depends(get_daily_summary_service),
    user_gateway: UserGateway = Depends(get_user_gateway),
):
    user, _ = await user_gateway.get_current_user()
    return await daily_summary_service.remove_meal_from_summary(user, meal_to_remove)


# DEV
@daily_summary_router.get(
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
