from typing import List, Optional

from fastapi import APIRouter, Depends, Query

from backend.diet_generation.dependencies import get_diet_generation_service
from backend.diet_generation.diet_generation_service import DietGenerationService
from backend.diet_generation.enums.meal_type import MealType
from backend.models import MealRecipe
from backend.models.meal_icon_model import MealIcon
from backend.users.enums.language import Language
from backend.users.user_gateway import UserGateway, get_user_gateway

diet_prediction_router = APIRouter(prefix="/v1/diet-prediction")


@diet_prediction_router.get("/meal-icon", response_model=MealIcon)
async def get_meal_icon_info(
    meal_type: MealType,
    meal_prediction_service: DietGenerationService = Depends(get_diet_generation_service),
    user_gateway: UserGateway = Depends(get_user_gateway),
):
    await user_gateway.get_current_user()
    return await meal_prediction_service.get_meal_icon(meal_type)


@diet_prediction_router.get("/meal-recipe/{recipe_id}", response_model=MealRecipe | List[MealRecipe])
async def get_meal_recipe_by_meal_id(
    recipe_id: int,
    language: Optional[Language] = Query(None),
    meal_prediction_service: DietGenerationService = Depends(get_diet_generation_service),
    user_gateway: UserGateway = Depends(get_user_gateway),
):
    await user_gateway.get_current_user()
    if language:
        return await meal_prediction_service.get_meal_recipe_by_meal_recipe_id_and_language(recipe_id, language)
    return await meal_prediction_service.get_meal_recipes_by_meal_recipe_id(recipe_id)


@diet_prediction_router.get("/meal-recipe", response_model=MealRecipe)
async def get_meal_recipe_by_id(
    uuid: int,
    meal_prediction_service: DietGenerationService = Depends(get_diet_generation_service),
    user_gateway: UserGateway = Depends(get_user_gateway),
):
    await user_gateway.get_current_user()
    return await meal_prediction_service.get_meal_recipe_by_uuid(uuid)


# TODO REMOVE IT
@diet_prediction_router.post("/meal-recipe", response_model=MealRecipe)
async def add_meal_recipe(
    meal_recipe: MealRecipe,
    meal_prediction_service: DietGenerationService = Depends(get_diet_generation_service),
    user_gateway: UserGateway = Depends(get_user_gateway),
):
    await user_gateway.get_current_user()
    return await meal_prediction_service.add_meal_recipe(meal_recipe)
