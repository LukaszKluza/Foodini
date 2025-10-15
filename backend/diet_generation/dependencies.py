from fastapi.params import Depends
from sqlmodel.ext.asyncio.session import AsyncSession

from backend.core.database import get_db
from backend.diet_generation.daily_summary_repository import DailySummaryRepository
from backend.diet_generation.daily_summary_service import DailySummaryService
from backend.diet_generation.daily_meals_generator_service import PromptService
from backend.diet_generation.diet_generation_service import DietGenerationService
from backend.diet_generation.meal_icons_repository import MealIconsRepository
from backend.diet_generation.meal_recipes_repository import MealRecipesRepository


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


async def get_daily_summary_repository(
    db: AsyncSession = Depends(get_db),
) -> DailySummaryRepository:
    return DailySummaryRepository(db)


async def get_daily_summary_service(
    daily_summary_repository: DailySummaryRepository = Depends(get_daily_summary_repository),
) -> DailySummaryService:
    return DailySummaryService(daily_summary_repository)


async def get_prompt_service(
    meal_recipes_repository: MealRecipesRepository = Depends(get_meal_recipes_repository),
) -> PromptService:
    return PromptService(meal_recipes_repository)
