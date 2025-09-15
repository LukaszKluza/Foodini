from diet_prediction.diet_prediction_service import MealIconsService
from fastapi.params import Depends
from sqlmodel.ext.asyncio.session import AsyncSession

from backend.core.database import get_db
from backend.diet_prediction.meal_icons_repository import MealIconsRepository


async def get_meal_icons_repository(
    db: AsyncSession = Depends(get_db),
) -> MealIconsRepository:
    return MealIconsRepository(db)


async def get_meal_icons_service(
    meal_icons_repository: MealIconsRepository = Depends(get_meal_icons_repository),
) -> MealIconsService:
    return MealIconsService(meal_icons_repository)
