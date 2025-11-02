from fastapi.params import Depends
from sqlmodel.ext.asyncio.session import AsyncSession

from backend.core.database import get_db
from backend.meals.meal_service import MealService
from backend.meals.repositories.meal_icons_repository import MealIconsRepository
from backend.meals.repositories.meal_recipes_repository import MealRecipesRepository
from backend.meals.repositories.meal_repository import MealRepository


async def get_meal_icons_repository(
    db: AsyncSession = Depends(get_db),
) -> MealIconsRepository:
    return MealIconsRepository(db)


async def get_meal_recipes_repository(
    db: AsyncSession = Depends(get_db),
) -> MealRecipesRepository:
    return MealRecipesRepository(db)


async def get_meal_repository(
    db: AsyncSession = Depends(get_db),
) -> MealRepository:
    return MealRepository(db)


async def get_meal_service(
    meal_icons_repository: MealIconsRepository = Depends(get_meal_icons_repository),
    meal_recipes_repository: MealRecipesRepository = Depends(get_meal_recipes_repository),
    meal_repository: MealRepository = Depends(get_meal_repository),
) -> MealService:
    return MealService(meal_recipes_repository, meal_repository, meal_icons_repository)
