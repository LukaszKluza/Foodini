from fastapi.params import Depends
from sqlmodel.ext.asyncio.session import AsyncSession

from backend.core.database import get_db
from backend.daily_summary.daily_summary_repository import DailySummaryRepository
from backend.daily_summary.daily_summary_service import DailySummaryService
from backend.meals.dependencies import get_meal_repository
from backend.meals.repositories.meal_repository import MealRepository


async def get_daily_summary_repository(
    db: AsyncSession = Depends(get_db),
) -> DailySummaryRepository:
    return DailySummaryRepository(db)


async def get_daily_summary_service(
    daily_summary_repository: DailySummaryRepository = Depends(get_daily_summary_repository),
    meal_repository: MealRepository = Depends(get_meal_repository),
) -> DailySummaryService:
    return DailySummaryService(daily_summary_repository, meal_repository)
