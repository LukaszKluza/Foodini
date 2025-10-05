from fastapi.params import Depends
from sqlmodel.ext.asyncio.session import AsyncSession

from backend.core.database import get_db
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
