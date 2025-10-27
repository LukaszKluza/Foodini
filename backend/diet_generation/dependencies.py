from fastapi.params import Depends

from backend.daily_summary.dependencies import get_daily_summary_repository
from backend.diet_generation.daily_meals_generator_service import PromptService
from backend.daily_summary.daily_summary_repository import DailySummaryRepository
from backend.meals.dependencies import get_meal_recipes_repository
from backend.meals.repositories.meal_recipes_repository import MealRecipesRepository
from backend.user_details.user_details_gateway import UserDetailsGateway, get_user_details_gateway


async def get_prompt_service(
    meal_recipes_repository: MealRecipesRepository = Depends(get_meal_recipes_repository),
    daily_summary_repository: DailySummaryRepository = Depends(get_daily_summary_repository),
    user_details_gateway: UserDetailsGateway = Depends(get_user_details_gateway),
) -> PromptService:
    return PromptService(meal_recipes_repository, daily_summary_repository, user_details_gateway)
