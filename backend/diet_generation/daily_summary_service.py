from datetime import date
from uuid import UUID

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
    MealInfo,
    MealInfoUpdateRequest,
)


class DailySummaryService:
    def __init__(self, summary_repo: DailySummaryRepository, meal_repo: MealRepository):
        self.daily_summary_repo = summary_repo
        self.meal_repo = meal_repo

    async def add_daily_meals(self, daily_meals_data: DailyMealsCreate, user_id: UUID):
        daily_meals = await self.daily_summary_repo.get_daily_meals_summary(user_id, daily_meals_data.day)
        if daily_meals:
            return await self.daily_summary_repo.update_daily_meals(user_id, daily_meals_data, daily_meals_data.day)
        return await self.daily_summary_repo.add_daily_meals_summary(daily_meals_data, user_id)

    async def get_daily_meals(self, user_id: UUID, day: date):
        daily_meals = await self.daily_summary_repo.get_daily_meals_summary(user_id, day)
        if not daily_meals:
            raise NotFoundInDatabaseException("Plan for given user and day does not exist.")
        return daily_meals

    async def add_daily_macros_summary(self, user_id: UUID, data: DailyMacrosSummaryCreate):
        daily_macros_summary = await self.daily_summary_repo.get_daily_macros_summary(user_id, data.day)
        if daily_macros_summary:
            return await self.daily_summary_repo.update_daily_macros_summary(user_id, data, data.day)
        return await self.daily_summary_repo.add_daily_macros_summary(data, user_id)

    async def get_daily_macros_summary(self, user_id: UUID, day: date):
        macros_summary = await self.daily_summary_repo.get_daily_macros_summary(user_id, day)
        if not macros_summary:
            raise NotFoundInDatabaseException("Plan for given user and day does not exist.")
        return macros_summary

    async def update_meal_status(self, user_id: UUID, meal_id: UUID, update_meal_data: MealInfoUpdateRequest):
        day = update_meal_data.day
        new_status = update_meal_data.status

        user_daily_meals = await self.daily_summary_repo.get_daily_meals_summary(user_id, day)
        if not user_daily_meals:
            raise NotFoundInDatabaseException("Plan for given user and day does not exist.")

        link_to_update = next((link for link in user_daily_meals.daily_meals if link.meal_id == meal_id), None)
        if not link_to_update:
            raise NotFoundInDatabaseException("Meal does not exist in user's plan for the given day.")

        previous_status = link_to_update.status

        meal_info = MealInfo(
            status=new_status,
            custom_name=link_to_update.meal.custom_name if hasattr(link_to_update.meal, "custom_name") else None,
            custom_calories=link_to_update.meal.custom_calories,
            custom_protein=link_to_update.meal.custom_protein,
            custom_carbs=link_to_update.meal.custom_carbs,
            custom_fat=link_to_update.meal.custom_fat,
            meal_id=meal_id,
        )

        await self._add_macros_after_status_change(user_id, day, meal_info, new_status, previous_status)

        await self._update_next_meal_status(
            link_to_update.meal.meal_type,
            {
                link.meal.meal_type.value: meal_info.model_dump(exclude_none=True)
                for link in user_daily_meals.daily_meals
            },
            new_status,
        )

        updated_summary = await self.daily_summary_repo.update_meal_status(user_id, day, meal_id, new_status)
        return updated_summary

    async def add_custom_meal(self, user_id: UUID, custom_meal: CustomMealUpdateRequest):
        day = custom_meal.day
        daily_meals = await self.daily_summary_repo.get_daily_meals_summary(user_id, day)
        if not daily_meals:
            raise NotFoundInDatabaseException("Plan for given user and day does not exist.")

        existing_link = await self.daily_summary_repo.get_meal_to_daily_summary(
            daily_summary_id=daily_meals.id, meal_id=custom_meal.meal_id
        )

        previous_status = MealStatus(existing_link.status) if existing_link else None

        meal_info = MealInfo(
            status=custom_meal.status,
            custom_name=custom_meal.custom_name,
            custom_calories=custom_meal.custom_calories,
            custom_protein=custom_meal.custom_protein,
            custom_carbs=custom_meal.custom_carbs,
            custom_fat=custom_meal.custom_fat,
            meal_id=None if custom_meal.custom_name else custom_meal.meal_id,
        )

        await self._add_macros_after_status_change(user_id, day, meal_info, custom_meal.status, previous_status)
        await self._update_next_meal_status(
            existing_link.meal.meal_type,
            {link.meal.meal_type.value: meal_info.model_dump(exclude_none=True) for link in existing_link.daily_meals},
            custom_meal.status,
        )
        updated_plan = await self.daily_summary_repo.add_custom_meal(user_id, day, {meal_info.meal_id: meal_info})
        return updated_plan

    async def add_meal_details(self, meal_data: MealCreate):
        return await self.meal_repo.add_meal(meal_data)

    async def get_meal_details(self, meal_id: UUID):
        meal = await self.meal_repo.get_meal_by_id(meal_id)
        if not meal:
            raise NotFoundInDatabaseException(f"Meal with id {meal_id} not found.")
        return meal

    async def _get_meal_calories(self, meal_id: UUID) -> int:
        calories = await self.meal_repo.get_meal_calories_by_id(meal_id)
        if calories is None:
            raise NotFoundInDatabaseException(f"Meal with id {meal_id} not found.")
        return calories

    async def _get_meal_macros(self, meal_id: UUID):
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

    async def _add_macros_to_daily_summary(self, user_id: UUID, data: DailyMacrosSummaryCreate):
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
        self, user_id: UUID, day: date, meal_info: MealInfo, status: MealStatus, previous_status: MealStatus
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
