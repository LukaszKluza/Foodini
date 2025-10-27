from datetime import date
from typing import List

from backend.core.not_found_in_database_exception import NotFoundInDatabaseException
from backend.daily_summary.daily_summary_repository import DailySummaryRepository
from backend.daily_summary.enums.meal_status import MealStatus
from backend.daily_summary.schemas import (
    CustomMealUpdateRequest,
    DailyMacrosSummaryCreate,
    DailyMealsCreate,
    MealInfo,
    MealInfoUpdateRequest,
)
from backend.meals.enums.meal_type import MealType
from backend.meals.repositories.meal_repository import MealRepository
from backend.meals.schemas import MealCreate


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

    # TODO: implement after database consolidation
    async def get_user_latest_meal_names(self, user_id: int, day: date) -> List[str]:
        return []

    async def update_meal_status(self, user_id: int, update_meal_data: MealInfoUpdateRequest):
        day = update_meal_data.day
        meal_type_enum = update_meal_data.meal_type
        new_status = update_meal_data.status

        user_daily_meals = await self.daily_summary_repo.get_daily_meals(user_id, day)
        if not user_daily_meals:
            raise NotFoundInDatabaseException("Plan for given user and day does not exist.")

        meals = user_daily_meals.meals
        existing_meal = meals.get(meal_type_enum)
        if not existing_meal:
            raise NotFoundInDatabaseException("Meal type does not exist in user's plan.")
        existing_meal_info = MealInfo(**existing_meal)

        previous_status = MealStatus(existing_meal_info.status) if MealStatus(existing_meal_info.status) else None

        meal_info = MealInfo(
            status=new_status,
            custom_name=existing_meal_info.custom_name,
            custom_calories=existing_meal_info.custom_calories,
            custom_protein=existing_meal_info.custom_protein,
            custom_carbs=existing_meal_info.custom_carbs,
            custom_fat=existing_meal_info.custom_fat,
            meal_id=existing_meal_info.meal_id,
        )

        meals[meal_type_enum.value] = meal_info.model_dump(exclude_none=True)

        await self._add_macros_after_status_change(user_id, day, meal_info, new_status, previous_status)

        await self._update_next_meal_status(meal_type_enum, meals, new_status)

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
        if not existing_meal:
            raise NotFoundInDatabaseException("Meal type does not exist in user's plan.")
        existing_meal = MealInfo(**existing_meal)

        previous_status = MealStatus(existing_meal.status) if MealStatus(existing_meal.status) else None

        meal_info = MealInfo(
            status=custom_meal.status,
            custom_name=custom_meal.custom_name,
            custom_calories=custom_meal.custom_calories,
            custom_protein=custom_meal.custom_protein,
            custom_carbs=custom_meal.custom_carbs,
            custom_fat=custom_meal.custom_fat,
            meal_id=existing_meal.meal_id if (not custom_meal.custom_name and existing_meal) else None,
        )

        meals[meal_type] = meal_info.model_dump(exclude_none=True)

        await self._add_macros_after_status_change(user_id, day, meal_info, custom_meal.status, previous_status)
        await self._update_next_meal_status(meal_type, meals, custom_meal.status)
        updated_plan = await self.daily_summary_repo.add_custom_meal(user_id, day, meals)
        return updated_plan

    async def add_meal_details(self, meal_data: MealCreate):
        return await self.meal_repo.add_meal(meal_data)

    async def get_meal_details(self, meal_id: int):
        meal = await self.meal_repo.get_meal_by_id(meal_id)
        if not meal:
            raise NotFoundInDatabaseException(f"Meal with id {meal_id} not found.")
        return meal

    async def _get_meal_calories(self, meal_id: int) -> int:
        calories = await self.meal_repo.get_meal_calories_by_id(meal_id)
        if calories is None:
            raise NotFoundInDatabaseException(f"Meal with id {meal_id} not found.")
        return calories

    async def _get_meal_macros(self, meal_id: int):
        protein = await self.meal_repo.get_meal_protein_by_id(meal_id)
        fat = await self.meal_repo.get_meal_fat_by_id(meal_id)
        carbs = await self.meal_repo.get_meal_carbs_by_id(meal_id)

        if None in (protein, fat, carbs):
            raise NotFoundInDatabaseException(f"Meal with id {meal_id} not found.")
        return {
            "protein": protein,
            "fat": fat,
            "carbs": carbs,
        }

    async def _add_macros_to_daily_summary(self, user_id: int, data: DailyMacrosSummaryCreate):
        user_daily_macros = await self.daily_summary_repo.get_daily_macros_summary(user_id, data.day)
        if not user_daily_macros:
            raise NotFoundInDatabaseException("Plan for given user and day does not exist.")

        data.calories += user_daily_macros.calories
        data.protein += user_daily_macros.protein
        data.carbs += user_daily_macros.carbs
        data.fat += user_daily_macros.fat

        await self.daily_summary_repo.update_daily_macros_summary(user_id, data, data.day)
        return user_daily_macros

    async def _add_macros_after_status_change(
        self, user_id: int, day: date, meal_info: MealInfo, status: MealStatus, previous_status: MealStatus
    ):
        if status != MealStatus.EATEN or previous_status == MealStatus.EATEN:
            return

        calories = meal_info.custom_calories
        protein = meal_info.custom_protein
        carbs = meal_info.custom_carbs
        fat = meal_info.custom_fat
        meal_id = meal_info.meal_id

        if None in (calories, protein, carbs, fat) and meal_id:
            db_calories = await self._get_meal_calories(meal_id)
            db_macros = await self._get_meal_macros(meal_id)
            calories = calories if calories is not None else db_calories
            protein = protein if protein is not None else db_macros["protein"]
            carbs = carbs if carbs is not None else db_macros["carbs"]
            fat = fat if fat is not None else db_macros["fat"]

        calories = calories or 0
        protein = protein or 0
        carbs = carbs or 0
        fat = fat or 0

        data = DailyMacrosSummaryCreate(
            day=day,
            calories=calories,
            protein=protein,
            carbs=carbs,
            fat=fat,
        )

        await self._add_macros_to_daily_summary(user_id, data)

    async def _update_next_meal_status(self, meal_type_enum: MealType, meals: dict, status: MealStatus):
        if status not in [MealStatus.EATEN, MealStatus.SKIPPED]:
            return

        sorted_meals = MealType.sorted_meals()
        current_idx = sorted_meals.index(meal_type_enum)

        for next_idx in range(current_idx + 1, len(sorted_meals)):
            next_meal_enum = sorted_meals[next_idx]
            next_meal = meals.get(next_meal_enum.value)
            if next_meal:
                next_meal_info = MealInfo(**next_meal)
                if next_meal_info.status == MealStatus.TO_EAT.value:
                    next_meal_info.status = MealStatus.PENDING
                    for key, value in next_meal_info.model_dump(exclude_none=True).items():
                        if isinstance(value, MealStatus):
                            value = value.value
                        next_meal[key] = value
                    break
