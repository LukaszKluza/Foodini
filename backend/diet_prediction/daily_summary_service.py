from datetime import date
from typing import Optional

from backend.diet_prediction.daily_summary_repository import DailySummaryRepository
from backend.diet_prediction.schemas import DailyMacrosSummaryCreate, DailyMealsCreate, MealInfoUpdateRequest
from backend.models.user_daily_summary_model import DailyMacrosSummary, DailyMeals
from backend.user_details.service.user_details_validation_service import UserDetailsValidationService


class DailySummaryService:
    def __init__(self, meals_repo: DailySummaryRepository, user_details_validators: UserDetailsValidationService):
        self.daily_summary_repo = meals_repo
        self.user_details_validators = user_details_validators

    async def get_user_details_by_user(self, user_id: int):
        return await self.user_details_validators.ensure_user_details_exist_by_user_id(user_id)

    async def add_daily_meals(self, daily_meals_data: DailyMealsCreate, user_id: int) -> DailyMeals:
        await self.get_user_details_by_user(user_id)
        daily_meals = await self.daily_summary_repo.get_daily_meals(user_id, daily_meals_data.day)
        if daily_meals:
            raise ValueError(f"Daily meals already exist for user {user_id} and day {daily_meals_data.day}")
        return await self.daily_summary_repo.add_daily_meals(daily_meals_data, user_id)

    async def get_daily_meals(self, user_id: int, day: date) -> Optional[DailyMeals]:
        await self.get_user_details_by_user(user_id)
        return await self.daily_summary_repo.get_daily_meals(user_id, day)

    async def add_daily_macros_summary(self, user_id: int, data: DailyMacrosSummaryCreate) -> DailyMacrosSummary:
        await self.get_user_details_by_user(user_id)
        daily_macros_summary = await self.daily_summary_repo.get_daily_macros_summary(user_id, data.day)
        if daily_macros_summary:
            raise ValueError(f"Daily macros summary already exist for user {user_id} and day {data.day}.")
        return await self.daily_summary_repo.add_daily_macros_summary(data, user_id)

    async def get_daily_macros_summary(self, user_id: int, day: date) -> Optional[DailyMacrosSummary]:
        await self.get_user_details_by_user(user_id)
        return await self.daily_summary_repo.get_daily_macros_summary(user_id, day)

    async def update_daily_macros_summary(self, user_id: int, data: DailyMacrosSummaryCreate) -> DailyMacrosSummary:
        await self.get_user_details_by_user(user_id)
        return await self.daily_summary_repo.update_daily_macros_summary(user_id, data)

    async def update_meal_status(self, user_id: int, update_data: MealInfoUpdateRequest) -> DailyMeals:
        updated_meals = await self.daily_summary_repo.update_meal_status(user_id, update_data)
        if not updated_meals:
            raise ValueError("Plan for given user and day does not exist or there is no wanted meal.")
        return updated_meals
