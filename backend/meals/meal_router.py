from typing import List, Optional

from fastapi import APIRouter, Depends, Query

from backend.meals.dependencies import get_meal_service
from backend.meals.meal_service import MealService
from backend.meals.enums.meal_type import MealType
from backend.models import MealRecipe
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


@meal_router.get("/meal-recipe/{meal_id}", response_model=MealRecipe | List[MealRecipe])
async def get_meal_recipe_by_meal_id(
    meal_id: int,
    language: Optional[Language] = Query(None),
    meal_service: MealService = Depends(get_meal_service),
    user_gateway: UserGateway = Depends(get_user_gateway),
):
    await user_gateway.get_current_user()
    if language:
        return await meal_service.get_meal_recipe_by_meal_recipe_id_and_language(meal_id, language)
    return await meal_service.get_meal_recipes_by_meal_recipe_id(meal_id)


@meal_router.get("/meal-recipe", response_model=MealRecipe)
async def get_meal_recipe_by_id(
    recipe_id: int,
    meal_service: MealService = Depends(get_meal_service),
    user_gateway: UserGateway = Depends(get_user_gateway),
):
    await user_gateway.get_current_user()
    return await meal_service.get_meal_recipe_by_recipe_id(recipe_id)