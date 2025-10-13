from fastapi.params import Depends
from sqlmodel.ext.asyncio.session import AsyncSession

from backend.core.database import get_db
from backend.diet_generation.daily_meals_generator_service import PromptService
from backend.diet_generation.diet_generation_service import DietGenerationService
from backend.diet_generation.meal_icons_repository import MealIconsRepository
from backend.diet_generation.meal_recipes_repository import MealRecipesRepository
from backend.user_details.calories_prediction_repository import CaloriesPredictionRepository
from backend.user_details.dependencies import get_calories_prediction_repository, get_user_details_repository
from backend.user_details.user_details_repository import UserDetailsRepository


async def get_meal_icons_repository(
    db: AsyncSession = Depends(get_db),
) -> MealIconsRepository:
    return MealIconsRepository(db)


async def get_meal_recipes_repository(
    db: AsyncSession = Depends(get_db),
) -> MealRecipesRepository:
    return MealRecipesRepository(db)


async def get_diet_generation_service(
    meal_icons_repository: MealIconsRepository = Depends(get_meal_icons_repository),
    meal_recipes_repository: MealRecipesRepository = Depends(get_meal_recipes_repository),
) -> DietGenerationService:
    return DietGenerationService(meal_icons_repository, meal_recipes_repository)


async def get_prompt_service(
    meal_recipes_repository: MealRecipesRepository = Depends(get_meal_recipes_repository),
) -> PromptService:
    return PromptService(meal_recipes_repository)
