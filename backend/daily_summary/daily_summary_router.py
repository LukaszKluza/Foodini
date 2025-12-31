from datetime import date

from fastapi import APIRouter, Depends

from backend.core.role_sets import user_or_admin
from backend.daily_summary.daily_summary_service import DailySummaryService
from backend.daily_summary.dependencies import get_daily_summary_service
from backend.daily_summary.schemas import (
    ComposedMealUpdateRequest,
    DailySummary,
    MealInfoUpdateRequest,
    MealMacros,
    RemoveMealRequest,
    RemoveMealResponse,
)
from backend.models import ComposedMealItem
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


@daily_summary_router.post(
    "/meals",
    response_model=ComposedMealItem,
    summary="Add custom meal",
    description="Add a custom meal created by the user to their proper daily summary.",
)
async def add_meal(
    custom_meal: ComposedMealUpdateRequest,
    daily_summary_service: DailySummaryService = Depends(get_daily_summary_service),
    user_gateway: UserGateway = Depends(get_user_gateway),
):
    user, _ = await user_gateway.get_current_user()
    return await daily_summary_service.add_custom_meal(user, custom_meal)


@daily_summary_router.patch(
    "/meals/{meal_id}",
    response_model=ComposedMealItem,
    summary="Edit meal",
    description="Edit a wight eaten by the user for a specific meal in their daily summary.",
)
async def edit_meal(
    custom_meal: ComposedMealUpdateRequest,
    daily_summary_service: DailySummaryService = Depends(get_daily_summary_service),
    user_gateway: UserGateway = Depends(get_user_gateway),
):
    user, _ = await user_gateway.get_current_user()
    return await daily_summary_service.edit_meal(user, custom_meal)


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
