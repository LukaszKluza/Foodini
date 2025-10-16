from datetime import date

from backend.core.not_found_in_database_exception import NotFoundInDatabaseException
from backend.diet_generation.daily_summary_repository import DailySummaryRepository
from backend.diet_generation.enums.meal_status import MealStatus
from backend.diet_generation.enums.meal_type import MealType
from backend.diet_generation.schemas import (
    CustomMealUpdateRequest,
    DailyMacrosSummaryCreate,
    DailyMealsCreate,
    MealInfoUpdateRequest,
)


class DailySummaryService:
    def __init__(self, meals_repo: DailySummaryRepository):
        self.daily_summary_repo = meals_repo

    async def add_daily_meals(self, daily_meals_data: DailyMealsCreate, user_id: int):
        daily_meals = await self.daily_summary_repo.get_daily_meals(user_id, daily_meals_data.day)
        if daily_meals:
            return await self.daily_summary_repo.update_daily_meals(user_id, daily_meals_data, daily_meals_data.day)
        return await self.daily_summary_repo.add_daily_meals(daily_meals_data, user_id)

    async def get_daily_meals(self, user_id: int, day: date):
        daily_meals = await self.daily_summary_repo.get_daily_meals(user_id, day)
        if not daily_meals:
            raise NotFoundInDatabaseException("Plan for given user and day does not exist.")
        return daily_meals

    async def add_daily_macros_summary(self, user_id: int, data: DailyMacrosSummaryCreate):
        daily_macros_summary = await self.daily_summary_repo.get_daily_macros_summary(user_id, data.day)
        if daily_macros_summary:
            return await self.daily_summary_repo.update_daily_macros_summary(user_id, data, data.day)
        return await self.daily_summary_repo.add_daily_macros_summary(data, user_id)

    async def get_daily_macros_summary(self, user_id: int, day: date):
        macros_summary = await self.daily_summary_repo.get_daily_macros_summary(user_id, day)
        if not macros_summary:
            raise NotFoundInDatabaseException("Plan for given user and day does not exist.")
        return macros_summary

    # Temporary not used
    async def update_daily_macros_summary(self, user_id: int, data: DailyMacrosSummaryCreate):
        user_daily_macros = await self.daily_summary_repo.get_daily_macros_summary(user_id, data.day)
        if not user_daily_macros:
            raise NotFoundInDatabaseException("Plan for given user and day does not exist.")

        user_daily_macros.calories = data.calories
        user_daily_macros.protein = data.protein
        user_daily_macros.carbs = data.carbs
        user_daily_macros.fats = data.fats

        await self.daily_summary_repo.update_daily_macros_summary(user_id, data.day, user_daily_macros)
        return user_daily_macros

    async def update_meal_status(self, user_id: int, update_meal_data: MealInfoUpdateRequest):
        day = update_meal_data.day
        meal_type_enum = update_meal_data.meal_type
        status = update_meal_data.status.value

        user_daily_meals = await self.daily_summary_repo.get_daily_meals(user_id, day)
        if not user_daily_meals:
            raise NotFoundInDatabaseException("Plan for given user and day does not exist.")

        meals = user_daily_meals.meals
        if meal_type_enum.value not in meals:
            raise NotFoundInDatabaseException("Meal type does not exist in user's plan.")

        meals[meal_type_enum.value]["status"] = status

        sorted_meals = MealType.sorted_meals()
        current_idx = sorted_meals.index(meal_type_enum)
        for next_idx in range(current_idx + 1, len(sorted_meals)):
            next_meal_enum = sorted_meals[next_idx]
            next_meal = meals.get(next_meal_enum.value)
            if next_meal:
                next_status = next_meal["status"]
                print(status, next_status)
                if (
                    status in [MealStatus.EATEN.value, MealStatus.SKIPPED.value]
                    and next_status == MealStatus.TO_EAT.value
                ):
                    next_meal["status"] = MealStatus.PENDING.value
                break

        user_daily_meals.meals = meals

        updated_meals = await self.daily_summary_repo.update_meal_status(user_id, day, meals)
        return updated_meals

    async def add_custom_meal(self, user_id: int, custom_meal: CustomMealUpdateRequest):
        day = custom_meal.day
        daily_meals = await self.daily_summary_repo.get_daily_meals(user_id, day)
        if not daily_meals:
            raise NotFoundInDatabaseException("Plan for given user and day does not exist.")

        meals = daily_meals.meals

        meals[custom_meal.meal_type] = {
            "status": custom_meal.status.value,
            "custom_name": custom_meal.custom_name,
            "custom_calories": custom_meal.custom_calories,
            "custom_protein": custom_meal.custom_protein,
            "custom_carbs": custom_meal.custom_carbs,
            "custom_fats": custom_meal.custom_fats,
        }

        updated_plan = await self.daily_summary_repo.add_custom_meal(user_id, day, meals)
        return updated_plan
