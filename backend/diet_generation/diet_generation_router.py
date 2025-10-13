from typing import List, Optional

from fastapi import APIRouter, Depends, Query

from backend.diet_generation.daily_meals_generator_service import PromptService
from backend.diet_generation.dependencies import get_diet_generation_service, get_prompt_service
from backend.diet_generation.diet_generation_service import DietGenerationService
from backend.diet_generation.enums.meal_type import MealType
from backend.models import MealRecipe
from backend.models.meal_icon_model import MealIcon
from backend.user_details.user_details_gateway import UserDetailsGateway, get_user_details_gateway
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


@diet_prediction_router.get("/meal-recipe/{meal_id}", response_model=MealRecipe | List[MealRecipe])
async def get_meal_recipe_by_meal_id(
    meal_id: int,
    language: Optional[Language] = Query(None),
    meal_prediction_service: DietGenerationService = Depends(get_diet_generation_service),
    user_gateway: UserGateway = Depends(get_user_gateway),
):
    await user_gateway.get_current_user()
    if language:
        return await meal_prediction_service.get_meal_recipe_by_meal_recipe_id_and_language(meal_id, language)
    return await meal_prediction_service.get_meal_recipes_by_meal_recipe_id(meal_id)


@diet_prediction_router.get("/meal-recipe", response_model=MealRecipe)
async def get_meal_recipe_by_id(
    recipe_id: int,
    meal_prediction_service: DietGenerationService = Depends(get_diet_generation_service),
    user_gateway: UserGateway = Depends(get_user_gateway),
):
    await user_gateway.get_current_user()
    return await meal_prediction_service.get_meal_recipe_by_recipe_id(recipe_id)


@diet_prediction_router.post("/generate_meal_plan", response_model=MealRecipe | List[MealRecipe])
async def generate_meal_plan(
    prompt_service: PromptService = Depends(get_prompt_service),
    user_gateway: UserGateway = Depends(get_user_gateway),
    user_details_gateway: UserDetailsGateway = Depends(get_user_details_gateway),
):
    user, _ = await user_gateway.get_current_user()
    user_details = await user_details_gateway.get_user_details(user)
    user_diet_prediction = await user_details_gateway.get_user_diet_predictions(user)
    return await prompt_service.generate_meal_plan(user_details, user_diet_prediction)
