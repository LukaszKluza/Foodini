from datetime import date
from typing import List

from fastapi import APIRouter, Depends

from backend.diet_generation.daily_meals_generator_service import DailyMealsGeneratorService
from backend.diet_generation.dependencies import get_prompt_service
from backend.models import MealRecipe
from backend.users.user_gateway import UserGateway, get_user_gateway

diet_generation_router = APIRouter(prefix="/v1/diet-generation")


@diet_generation_router.post("/generate-meal-plan", response_model=MealRecipe | List[MealRecipe])
async def generate_meal_plan(
    day: date,
    prompt_service: DailyMealsGeneratorService = Depends(get_prompt_service),
    user_gateway: UserGateway = Depends(get_user_gateway),
):
    user, _ = await user_gateway.get_current_user()
    return await prompt_service.generate_meal_plan(user, day)
