from datetime import date

from backend.core.not_found_in_database_exception import NotFoundInDatabaseException
from backend.diet_generation.daily_summary_repository import DailySummaryRepository
from backend.diet_generation.enums.meal_status import MealStatus
from backend.diet_generation.enums.meal_type import MealType
from backend.diet_generation.meal_repository import MealRepository
from backend.diet_generation.schemas import (
    CustomMealUpdateRequest,
    DailyMacrosSummaryCreate,
    DailyMealsCreate,
    MealCreate,
    MealInfoUpdateRequest,
)


class DailySummaryService:
    def __init__(self, summary_repo: DailySummaryRepository, meal_repo: MealRepository):
        self.daily_summary_repo = summary_repo
        self.meal_repo = meal_repo

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

    async def add_macros_to_daily_summary(self, user_id: int, data: DailyMacrosSummaryCreate):
        user_daily_macros = await self.daily_summary_repo.get_daily_macros_summary(user_id, data.day)
        if not user_daily_macros:
            raise NotFoundInDatabaseException("Plan for given user and day does not exist.")

        data.calories += user_daily_macros.calories
        data.protein += user_daily_macros.protein
        data.carbs += user_daily_macros.carbs
        data.fats += user_daily_macros.fats

        await self.daily_summary_repo.update_daily_macros_summary(user_id, data, data.day)
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

        meal_info = meals[meal_type_enum.value]
        meal_info["status"] = status

        if status == MealStatus.EATEN.value:
            if meal_info.get("meal_id"):
                try:
                    meal_id = int(meal_info["meal_id"])
                except (TypeError, ValueError):
                    meal_id = None
                calories = await self.get_meal_calories(meal_id)
                macros = await self.get_meal_macros(meal_id)
                protein = macros["protein"]
                carbs = macros["carbs"]
                fats = macros["fats"]
            else:
                calories = meal_info.get("custom_calories", 0)
                protein = meal_info.get("custom_protein", 0)
                carbs = meal_info.get("custom_carbs", 0)
                fats = meal_info.get("custom_fats", 0)

            data = DailyMacrosSummaryCreate(
                day=day,
                calories=calories,
                protein=protein,
                carbs=carbs,
                fats=fats,
            )

            await self.add_macros_to_daily_summary(user_id, data)

        if status != MealStatus.PENDING.value:
            sorted_meals = MealType.sorted_meals()
            current_idx = sorted_meals.index(meal_type_enum)
            for next_idx in range(current_idx + 1, len(sorted_meals)):
                next_meal_enum = sorted_meals[next_idx]
                next_meal = meals.get(next_meal_enum.value)
                if next_meal:
                    next_status = next_meal["status"]
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
        meal_type = custom_meal.meal_type.value
        existing_meal = meals.get(meal_type)

        if not custom_meal.custom_name:
            meals[meal_type] = {
                "meal_id": existing_meal.get("meal_id") if existing_meal else None,
                "status": custom_meal.status.value,
                "custom_calories": custom_meal.custom_calories,
                "custom_protein": custom_meal.custom_protein,
                "custom_carbs": custom_meal.custom_carbs,
                "custom_fats": custom_meal.custom_fats,
            }
        else:
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

    async def add_meal_details(self, meal_data: MealCreate):
        meal = await self.meal_repo.get_meal_by_name(meal_data.meal_name)
        if meal:
            return await self.meal_repo.update_meal(meal_data)
        return await self.meal_repo.add_meal(meal_data)

    async def get_meal_details(self, meal_id: int):
        meal = await self.meal_repo.get_meal_by_id(meal_id)
        if not meal:
            raise NotFoundInDatabaseException(f"Meal with id {meal_id} not found.")
        return meal

    async def get_meal_calories(self, meal_id: int) -> int:
        calories = await self.meal_repo.get_meal_calories_by_id(meal_id)
        if calories is None:
            raise NotFoundInDatabaseException(f"Meal with id {meal_id} not found.")
        return calories

    async def get_meal_macros(self, meal_id: int):
        protein = await self.meal_repo.get_meal_protein_by_id(meal_id)
        fats = await self.meal_repo.get_meal_fats_by_id(meal_id)
        carbs = await self.meal_repo.get_meal_carbs_by_id(meal_id)

        if None in (protein, fats, carbs):
            raise NotFoundInDatabaseException(f"Meal with id {meal_id} not found.")
        return {
            "protein": protein,
            "fats": fats,
            "carbs": carbs,
        }
