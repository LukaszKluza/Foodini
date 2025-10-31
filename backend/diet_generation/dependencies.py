from fastapi.params import Depends
from sqlmodel.ext.asyncio.session import AsyncSession

from backend.core.database import get_db
from backend.daily_summary.daily_summary_gateway import DailySummaryGateway, get_daily_summary_gateway
from backend.diet_generation.daily_meals_generator_service import DailyMealsGeneratorService
from backend.diet_generation.last_generated_meals_repository import LastGeneratedMealsRepository
from backend.meals.meal_gateway import MealGateway, get_meal_gateway
from backend.user_details.user_details_gateway import UserDetailsGateway, get_user_details_gateway


async def get_last_generated_meals_repository(
    db: AsyncSession = Depends(get_db),
) -> LastGeneratedMealsRepository:
    return LastGeneratedMealsRepository(db)

async def get_prompt_service(
    meal_gateway: MealGateway = Depends(get_meal_gateway),
    daily_summary_gateway: DailySummaryGateway = Depends(get_daily_summary_gateway),
    user_details_gateway: UserDetailsGateway = Depends(get_user_details_gateway),
) -> DailyMealsGeneratorService:
    return DailyMealsGeneratorService(meal_gateway, daily_summary_gateway, user_details_gateway)
