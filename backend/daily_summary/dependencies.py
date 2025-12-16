from fastapi.params import Depends
from sqlmodel.ext.asyncio.session import AsyncSession

from backend.core.database import get_db
from backend.daily_summary.composed_meal_items_service import ComposedMealItemsService
from backend.daily_summary.daily_summary_service import DailySummaryService
from backend.daily_summary.repositories.composed_meal_items_repository import ComposedMealItemsRepository
from backend.daily_summary.repositories.daily_summary_repository import DailySummaryRepository
from backend.daily_summary.repositories.last_generated_meals_repository import LastGeneratedMealsRepository
from backend.meals.dependencies import get_meal_repository
from backend.meals.meal_gateway import MealGateway, get_meal_gateway
from backend.meals.repositories.meal_repository import MealRepository
from backend.user_details.user_details_gateway import UserDetailsGateway, get_user_details_gateway


async def get_last_generated_meals_repository(
    db: AsyncSession = Depends(get_db),
) -> LastGeneratedMealsRepository:
    return LastGeneratedMealsRepository(db)


async def get_daily_summary_repository(
    db: AsyncSession = Depends(get_db),
) -> DailySummaryRepository:
    return DailySummaryRepository(db)


async def get_composed_meal_items_repository(
    db: AsyncSession = Depends(get_db),
) -> ComposedMealItemsRepository:
    return ComposedMealItemsRepository(db)


async def get_composed_meal_items_service(
    daily_summary_repository: DailySummaryRepository = Depends(get_daily_summary_repository),
    composed_meal_items_repository: ComposedMealItemsRepository = Depends(get_composed_meal_items_repository),
    meal_gateway: MealGateway = Depends(get_meal_gateway),
) -> ComposedMealItemsService:
    return ComposedMealItemsService(
        daily_summary_repository,
        composed_meal_items_repository,
        meal_gateway,
    )


async def get_daily_summary_service(
    daily_summary_repository: DailySummaryRepository = Depends(get_daily_summary_repository),
    meal_repository: MealRepository = Depends(get_meal_repository),
    last_generated_meals_repository: LastGeneratedMealsRepository = Depends(get_last_generated_meals_repository),
    composed_meal_items_service: ComposedMealItemsService = Depends(get_composed_meal_items_service),
    meal_gateway: MealGateway = Depends(get_meal_gateway),
    user_details_gateway: UserDetailsGateway = Depends(get_user_details_gateway),
) -> DailySummaryService:
    return DailySummaryService(
        daily_summary_repository,
        meal_repository,
        last_generated_meals_repository,
        composed_meal_items_service,
        meal_gateway,
        user_details_gateway,
    )
