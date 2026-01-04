from typing import List, Optional
from uuid import UUID

from fastapi import APIRouter, Depends, Query, Request

from backend.core.role_sets import user_or_admin
from backend.meals.dependencies import get_meal_service
from backend.meals.enums.meal_type import MealType
from backend.meals.meal_service import MealService
from backend.meals.schemas import MealRecipeResponse
from backend.models.meal_icon_model import MealIcon
from backend.users.enums.language import Language
from backend.users.user_gateway import UserGateway, get_user_gateway

meal_router = APIRouter(prefix="/v1/meals", tags=["User", "Admin"], dependencies=[user_or_admin])


@meal_router.get(
    "/meal-icon",
    response_model=MealIcon,
    summary="Get meal icon information",
    description="Retrieves icon information for a specific meal type. One icon is assigned to all meals of one type.",
)
async def get_meal_icon_info(
    request: Request,
    meal_type: MealType,
    meal_service: MealService = Depends(get_meal_service),
    user_gateway: UserGateway = Depends(get_user_gateway),
):
    await user_gateway.get_current_user()
    return await meal_service.get_meal_icon(meal_type)


# TODO Admin only endpoint
@meal_router.get(
    "/admin/meal-recipes/{meal_id}",
    response_model=List[MealRecipeResponse],
    summary="Get all meal recipes (Admin)",
    description="Retrieves all recipes for a specific meal by its ID. This endpoint is intended for admin use only.",
)
async def get_meal_recipe_by_meal_id(
    request: Request,
    meal_id: UUID,
    language: Optional[Language] = Query(None),
    meal_service: MealService = Depends(get_meal_service),
    user_gateway: UserGateway = Depends(get_user_gateway),
):
    await user_gateway.get_current_user()
    return await meal_service.get_meal_recipes(meal_id, language)


@meal_router.get(
    "/meal-recipes/{meal_id}",
    response_model=MealRecipeResponse,
    summary="Get meal recipe",
    description="Retrieves a safe version of the recipe for a specific meal by its ID and optionally "
    "filtered by language.",
)
async def get_safe_meal_recipe_by_meal_id(
    request: Request,
    meal_id: UUID,
    language: Optional[Language] = Query(None),
    meal_service: MealService = Depends(get_meal_service),
    user_gateway: UserGateway = Depends(get_user_gateway),
):
    await user_gateway.get_current_user()
    return await meal_service.get_meal_recipe_by_meal_and_language_safe(meal_id, language)
