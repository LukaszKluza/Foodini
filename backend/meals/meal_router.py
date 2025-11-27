from typing import List, Optional
from uuid import UUID

from fastapi import APIRouter, Depends, Query

from backend.meals.dependencies import get_meal_service
from backend.meals.enums.meal_type import MealType
from backend.meals.meal_service import MealService
from backend.meals.schemas import MealRecipeResponse
from backend.models.meal_icon_model import MealIcon
from backend.users.enums.language import Language
from backend.users.user_gateway import UserGateway, get_user_gateway

meal_router = APIRouter(prefix="/v1/meals")


@meal_router.get("/meal-icon", response_model=MealIcon)
async def get_meal_icon_info(
    meal_type: MealType,
    meal_service: MealService = Depends(get_meal_service),
    user_gateway: UserGateway = Depends(get_user_gateway),
):
    await user_gateway.get_current_user()
    return await meal_service.get_meal_icon(meal_type)


# TODO Admin only endpoint
@meal_router.get("/admin/meal-recipes/{meal_id}", response_model=List[MealRecipeResponse])
async def get_meal_recipe_by_meal_id(
    meal_id: UUID,
    language: Optional[Language] = Query(None),
    meal_service: MealService = Depends(get_meal_service),
    user_gateway: UserGateway = Depends(get_user_gateway),
):
    await user_gateway.get_current_user()
    return await meal_service.get_meal_recipes(meal_id, language)


@meal_router.get("/meal-recipes/{meal_id}", response_model=MealRecipeResponse)
async def get_safe_meal_recipe_by_meal_id(
    meal_id: UUID,
    language: Optional[Language] = Query(None),
    meal_service: MealService = Depends(get_meal_service),
    user_gateway: UserGateway = Depends(get_user_gateway),
):
    await user_gateway.get_current_user()
    return await meal_service.get_meal_recipe_by_meal_and_language_safe(meal_id, language)
