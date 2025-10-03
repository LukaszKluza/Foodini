from fastapi.params import Depends
from sqlmodel.ext.asyncio.session import AsyncSession

from backend.core.database import get_db
from backend.diet_prediction.diet_prediction_service import DietPredictionsService
from backend.diet_prediction.meal_icons_repository import MealIconsRepository
from backend.diet_prediction.meal_recipes_repository import MealRecipesRepository


async def get_meal_icons_repository(
    db: AsyncSession = Depends(get_db),
) -> MealIconsRepository:
    return MealIconsRepository(db)


async def get_meal_recipes_repository(
    db: AsyncSession = Depends(get_db),
) -> MealRecipesRepository:
    return MealRecipesRepository(db)

async def get_diet_prediction_service(
    meal_icons_repository: MealIconsRepository = Depends(get_meal_icons_repository),
    meal_recipes_repository: MealRecipesRepository = Depends(get_meal_recipes_repository),
) -> DietPredictionsService:
    return DietPredictionsService(meal_icons_repository, meal_recipes_repository)
