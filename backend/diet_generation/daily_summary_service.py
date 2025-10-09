from datetime import date
from typing import Optional

from backend.core.not_found_in_database_exception import NotFoundInDatabaseException
from backend.diet_generation.daily_summary_repository import DailySummaryRepository
from backend.diet_generation.schemas import (
    CustomMealUpdateRequest,
    DailyMacrosSummaryCreate,
    DailyMealsCreate,
    MealInfoUpdateRequest,
)
from backend.models.user_daily_summary_model import DailyMacrosSummary, DailyMeals
from backend.users.service.user_validation_service import UserValidationService


class DailySummaryService:
    def __init__(self, meals_repo: DailySummaryRepository, user_validators: UserValidationService):
        self.daily_summary_repo = meals_repo
        self.user_validators = user_validators

    async def verify_user_exist(self, user_id: int):
        return await self.user_validators.ensure_user_exists_by_id(user_id)

    async def add_daily_meals(self, daily_meals_data: DailyMealsCreate, user_id: int) -> DailyMeals:
        await self.verify_user_exist(user_id)
        daily_meals = await self.daily_summary_repo.get_daily_meals(user_id, daily_meals_data.day)
        if daily_meals:
            raise ValueError(f"Daily meals already exist for user {user_id} and day {daily_meals_data.day}")
        return await self.daily_summary_repo.add_daily_meals(daily_meals_data, user_id)

    async def get_daily_meals(self, user_id: int, day: date) -> DailyMeals:
        await self.verify_user_exist(user_id)
        daily_meals = await self.daily_summary_repo.get_daily_meals(user_id, day)
        if not daily_meals:
            raise NotFoundInDatabaseException("Plan for given user and day does not exist.")
        return daily_meals

    async def add_daily_macros_summary(self, user_id: int, data: DailyMacrosSummaryCreate) -> DailyMacrosSummary:
        await self.verify_user_exist(user_id)
        daily_macros_summary = await self.daily_summary_repo.get_daily_macros_summary(user_id, data.day)
        if daily_macros_summary:
            raise ValueError(f"Daily macros summary already exist for user {user_id} and day {data.day}.")
        return await self.daily_summary_repo.add_daily_macros_summary(data, user_id)

    async def get_daily_macros_summary(self, user_id: int, day: date) -> Optional[DailyMacrosSummary]:
        await self.verify_user_exist(user_id)
        macros_summary = await self.daily_summary_repo.get_daily_macros_summary(user_id, day)
        if not macros_summary:
            raise NotFoundInDatabaseException("Plan for given user and day does not exist.")
        return macros_summary

    async def update_daily_macros_summary(self, user_id: int, data: DailyMacrosSummaryCreate) -> DailyMacrosSummary:
        await self.verify_user_exist(user_id)
        updated_macros_summary = await self.daily_summary_repo.update_daily_macros_summary(user_id, data)
        if not updated_macros_summary:
            raise NotFoundInDatabaseException("Plan for given user and day does not exist.")
        return updated_macros_summary

    async def update_meal_status(self, user_id: int, update_data: MealInfoUpdateRequest) -> DailyMeals:
        await self.verify_user_exist(user_id)
        updated_meals = await self.daily_summary_repo.update_meal_status(user_id, update_data)
        if not updated_meals:
            raise NotFoundInDatabaseException("Plan for given user and day does not exist or there is no wanted meal.")
        return updated_meals

    async def update_custom_meal(self, user_id: int, custom_meal: CustomMealUpdateRequest) -> DailyMeals:
        await self.verify_user_exist(user_id)
        updated_plan = await self.daily_summary_repo.update_custom_meal(user_id, custom_meal)
        if not updated_plan:
            raise NotFoundInDatabaseException("Plan for given user and day does not exist.")
        return updated_plan
