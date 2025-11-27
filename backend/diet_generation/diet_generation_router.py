from datetime import date
from typing import List

from fastapi import APIRouter, Depends, Request

from backend.core.limiter import limiter, user_target_date_key
from backend.diet_generation.daily_meals_generator_service import DailyMealsGeneratorService
from backend.diet_generation.dependencies import get_prompt_service
from backend.models import MealRecipe
from backend.users.user_gateway import UserGateway, get_user_gateway

diet_generation_router = APIRouter(prefix="/v1/diet-generation")


@diet_generation_router.post("/generate-meal-plan", response_model=List[MealRecipe])
@limiter.limit("3/day", key_func=user_target_date_key)
@limiter.limit("1 per 2 minutes", key_func=user_target_date_key)
async def generate_meal_plan(
    request: Request,
    day: date,
    prompt_service: DailyMealsGeneratorService = Depends(get_prompt_service),
    user_gateway: UserGateway = Depends(get_user_gateway),
):
    user, _ = await user_gateway.get_current_user()
    return await prompt_service.generate_meal_plan(user, day)
