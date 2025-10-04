from fastapi.params import Depends
from sqlmodel.ext.asyncio.session import AsyncSession

from backend.core.database import get_db
from backend.diet_prediction.daily_summary_repository import DailySummaryRepository
from backend.diet_prediction.daily_summary_service import DailySummaryService
from backend.diet_prediction.diet_prediction_service import MealIconsService
from backend.diet_prediction.meal_icons_repository import MealIconsRepository


async def get_meal_icons_repository(
    db: AsyncSession = Depends(get_db),
) -> MealIconsRepository:
    return MealIconsRepository(db)


async def get_meal_icons_service(
    meal_icons_repository: MealIconsRepository = Depends(get_meal_icons_repository),
) -> MealIconsService:
    return MealIconsService(meal_icons_repository)


async def get_daily_summary_repository(
    db: AsyncSession = Depends(get_db),
) -> DailySummaryRepository:
    return DailySummaryRepository(db)


async def get_daily_summary_service(
    daily_summary_repository: DailySummaryRepository = Depends(get_daily_summary_repository),
) -> DailySummaryService:
    return DailySummaryService(daily_summary_repository)
