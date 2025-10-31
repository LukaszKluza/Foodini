from typing import List, Optional
from uuid import UUID

from fastapi import APIRouter, Depends

from backend.diet_generation.daily_meals_generator_service import PromptService
from backend.diet_generation.dependencies import get_diet_generation_service, get_prompt_service
from backend.diet_generation.diet_generation_service import DietGenerationService
from backend.diet_generation.enums.meal_type import MealType
from backend.diet_generation.schemas import MealRecipeResponse
from backend.models import MealRecipe
from backend.models.meal_icon_model import MealIcon
from backend.users.enums.language import Language
from backend.users.user_gateway import UserGateway, get_user_gateway

diet_generation_router = APIRouter(prefix="/v1/diet-generation")
diet_generation_router = APIRouter(prefix="/v1/diet-prediction")


@diet_generation_router.get("/meal-icon", response_model=MealIcon)
async def get_meal_icon_info(
    meal_type: MealType,
    meal_prediction_service: DietGenerationService = Depends(get_diet_generation_service),
    user_gateway: UserGateway = Depends(get_user_gateway),
):
    await user_gateway.get_current_user()
    return await meal_prediction_service.get_meal_icon(meal_type)


@diet_generation_router.get("/meal-recipes/{meal_id}", response_model=MealRecipeResponse | List[MealRecipeResponse])
async def get_meal_recipe_by_meal_id(
    meal_id: UUID,
    language: Optional[Language] = Query(None),
    meal_prediction_service: DietGenerationService = Depends(get_diet_generation_service),
    user_gateway: UserGateway = Depends(get_user_gateway),
):
    await user_gateway.get_current_user()
    if language:
        return await meal_prediction_service.get_meal_recipe_by_meal_recipe_id_and_language(meal_id, language)
    return await meal_prediction_service.get_meal_recipes_by_meal_recipe_id(meal_id)


@diet_generation_router.post("/generate_meal_plan", response_model=MealRecipe | List[MealRecipe])
async def generate_meal_plan(
    day: date,
    prompt_service: DailyMealsGeneratorService = Depends(get_prompt_service),
    user_gateway: UserGateway = Depends(get_user_gateway),
):
    user, _ = await user_gateway.get_current_user()
    return await prompt_service.generate_meal_plan(user, day)
