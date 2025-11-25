from datetime import date
from typing import List, Type
from uuid import UUID

from backend.core.logger import logger
from backend.core.not_found_in_database_exception import NotFoundInDatabaseException
from backend.daily_summary.enums.meal_status import MealStatus
from backend.daily_summary.repositories.daily_summary_repository import DailySummaryRepository
from backend.daily_summary.repositories.last_generated_meals_repository import LastGeneratedMealsRepository
from backend.daily_summary.schemas import (
    BasicMealInfo,
    CustomMealUpdateRequest,
    DailyMacrosSummaryCreate,
    DailyMealsCreate,
    DailySummary,
    MealInfo,
    MealInfoUpdateRequest,
    MealInfoWithIconPath,
)
from backend.meals.enums.meal_type import MealType
from backend.meals.meal_gateway import MealGateway
from backend.meals.repositories.meal_repository import MealRepository
from backend.meals.schemas import MealCreate
from backend.models import DailyMealsSummary, Ingredient, Ingredients, MealRecipe, User
from backend.user_details.user_details_gateway import UserDetailsGateway


class DailySummaryService:
    def __init__(
        self,
        summary_repo: DailySummaryRepository,
        meal_repo: MealRepository,
        last_generated_meals_repo: LastGeneratedMealsRepository,
        meal_gateway: MealGateway,
        user_details_gateway: UserDetailsGateway,
    ):
        self.daily_summary_repo = summary_repo
        self.meal_repo = meal_repo
        self.last_generated_meals_repo = last_generated_meals_repo
        self.meal_gateway = meal_gateway
        self.user_details_gateway = user_details_gateway

    async def get_daily_summary(self, user: Type[User], day: date):
        daily_meals = await self.daily_summary_repo.get_daily_summary(user.id, day, user.language)
        if not daily_meals:
            logger.debug(f"No daily meals for {day} for user {user.id}")
            raise NotFoundInDatabaseException("Plan for given user and day does not exist.")

        meals_dict = {
            link.meal.meal_type.value: MealInfoWithIconPath(
                meal_id=link.meal.id,
                status=link.status,
                name=link.meal.recipes[0].meal_name,
                description=link.meal.recipes[0].meal_description,
                explanation=link.meal.recipes[0].meal_explanation,
                icon_path=await self.meal_gateway.get_meal_icon_path_by_id(link.meal.icon_id),
                calories=int(link.meal.calories),
                protein=float(link.meal.protein),
                carbs=float(link.meal.carbs),
                fat=float(link.meal.fat),
                weight=int(link.meal.weight),
            )
            for link in daily_meals.daily_meals
            if link.meal is not None
        }

        macros_summary = await self.get_daily_macros_summary(user.id, day)
        last_diet_prediction = await self.user_details_gateway.get_date_of_last_update_user_calories_prediction(user)
        last_user_details = await self.user_details_gateway.get_date_of_last_update_user_details(user)

        return DailySummary(
            day=daily_meals.day,
            meals=meals_dict,
            target_calories=daily_meals.target_calories,
            target_protein=daily_meals.target_protein,
            target_carbs=daily_meals.target_carbs,
            target_fat=daily_meals.target_fat,
            eaten_calories=macros_summary.calories,
            eaten_protein=macros_summary.protein,
            eaten_carbs=macros_summary.carbs,
            eaten_fat=macros_summary.fat,
            is_out_dated=(daily_meals.updated_at <= last_diet_prediction or daily_meals.updated_at <= last_user_details)
            and daily_meals.day >= date.today(),
        )

    async def add_daily_meals(self, daily_meals_data: DailyMealsCreate, user_id: UUID):
        daily_meals = await self.daily_summary_repo.get_daily_meals_summary(user_id, daily_meals_data.day)
        if daily_meals:
            await self.daily_summary_repo.update_daily_meals(user_id, daily_meals_data, daily_meals_data.day)
        else:
            await self.daily_summary_repo.add_daily_meals_summary(daily_meals_data, user_id)

        daily_meals = await self.daily_summary_repo.get_daily_meals_summary(user_id, daily_meals_data.day)

        meals_dict = {
            link.meal.meal_type: MealInfo(
                meal_id=link.meal.id,
                status=link.status,
                name=link.meal.recipes[0].meal_name,
                description=link.meal.recipes[0].meal_description,
                calories=int(link.meal.calories),
                protein=float(link.meal.protein),
                carbs=float(link.meal.carbs),
                fat=float(link.meal.fat),
            )
            for link in daily_meals.daily_meals
            if link.meal is not None
        }

        return DailyMealsCreate(
            day=daily_meals.day,
            meals=meals_dict,
            target_calories=daily_meals.target_calories,
            target_protein=float(daily_meals.target_protein),
            target_carbs=float(daily_meals.target_carbs),
            target_fat=float(daily_meals.target_fat),
        )

    async def get_daily_meals(self, user_id: UUID, day: date):
        daily_meals = await self.daily_summary_repo.get_daily_meals_summary(user_id, day)
        if not daily_meals:
            logger.debug(f"No plan for {day} for user {user_id}")
            raise NotFoundInDatabaseException("Plan for given user and day does not exist.")

        meals_dict = {
            link.meal.meal_type.value: MealInfo(
                meal_id=link.meal.id,
                name=link.meal.recipes[0].meal_name,
                description=link.meal.recipes[0].meal_description,
                status=link.status,
                calories=int(link.meal.calories),
                protein=float(link.meal.protein),
                carbs=float(link.meal.carbs),
                fat=float(link.meal.fat),
            )
            for link in daily_meals.daily_meals
            if link.meal is not None
        }

        return DailyMealsCreate(
            day=daily_meals.day,
            meals=meals_dict,
            target_calories=daily_meals.target_calories,
            target_protein=daily_meals.target_protein,
            target_carbs=daily_meals.target_carbs,
            target_fat=daily_meals.target_fat,
        )

    async def add_daily_macros_summary(self, user_id: UUID, data: DailyMacrosSummaryCreate):
        daily_macros_summary = await self.daily_summary_repo.get_daily_macros_summary(user_id, data.day)
        if daily_macros_summary:
            return await self.daily_summary_repo.update_daily_macros_summary(user_id, data, data.day)
        return await self.daily_summary_repo.add_daily_macros_summary(data, user_id)

    async def get_daily_macros_summary(self, user_id: UUID, day: date):
        macros_summary = await self.daily_summary_repo.get_daily_macros_summary(user_id, day)
        if not macros_summary:
            logger.debug(f"No plan for {day} for user {user_id}")
            raise NotFoundInDatabaseException("Plan for given user and day does not exist.")
        return macros_summary

    async def get_last_generated_meals(self, user_id: UUID, from_date: date, to_date: date) -> List[str]:
        return await self.last_generated_meals_repo.get_last_generated_meals(user_id, from_date, to_date)

    async def update_meal_status(self, user: Type[User], update_meal_data: MealInfoUpdateRequest):
        day = update_meal_data.day
        meal_id = update_meal_data.meal_id
        new_status = update_meal_data.status

        user_daily_meals = await self.daily_summary_repo.get_daily_meals_summary(user.id, day)
        if not user_daily_meals:
            logger.debug(f"No plan for {day} for user {user.id}")
            raise NotFoundInDatabaseException("Plan for given user and day does not exist.")

        link_to_update = next((link for link in user_daily_meals.daily_meals if link.meal_id == meal_id), None)
        if not link_to_update:
            logger.debug(f"Meal does not exist in {user.id} plan for {day}")
            raise NotFoundInDatabaseException("Meal does not exist in user's plan for the given day.")

        previous_status = link_to_update.status

        await self.daily_summary_repo.update_meal_status(user.id, day, meal_id, new_status)

        meal_info = BasicMealInfo(
            status=new_status,
            calories=int(link_to_update.meal.calories),
            protein=float(link_to_update.meal.protein),
            carbs=float(link_to_update.meal.carbs),
            fat=float(link_to_update.meal.fat),
            meal_id=meal_id,
            weight=link_to_update.meal.weight,
        )

        await self._update_macros_after_status_change(user.id, day, meal_info, new_status, previous_status)
        await self._update_next_meal_status(user_daily_meals)

        return meal_info

    async def add_custom_meal(self, user: Type[User], custom_meal: CustomMealUpdateRequest):
        day = custom_meal.day
        daily_meals = await self.daily_summary_repo.get_daily_summary(user.id, day, user.language)
        if not daily_meals:
            logger.debug(f"No plan for {day} for user {user.id}")
            raise NotFoundInDatabaseException("Plan for given user and day does not exist.")

        existing_link = next(
            (link for link in daily_meals.daily_meals if link.meal.id == custom_meal.meal_id),
            None,
        )

        if not existing_link:
            logger.debug(f"No meal {custom_meal.meal_id} for {day} for user {user.id}")
            raise NotFoundInDatabaseException(f"No meal of id: {custom_meal.meal_id} for this day.")

        previous_status = MealStatus(existing_link.status)
        existing_meal = existing_link.meal

        new_meal = MealCreate(
            meal_type=existing_meal.meal_type,
            icon_id=existing_meal.icon_id,
            calories=custom_meal.custom_calories or existing_meal.calories,
            protein=custom_meal.custom_protein or existing_meal.protein,
            carbs=custom_meal.custom_carbs or existing_meal.carbs,
            fat=custom_meal.custom_fat or existing_meal.fat,
        )

        new_meal = await self.meal_repo.add_meal(new_meal)
        new_name = custom_meal.custom_name or existing_link.meal.recipes[0].meal_name

        new_meal_id = new_meal.id
        await self.meal_gateway.add_meal_recipe(
            MealRecipe(
                meal_id=new_meal_id,
                language=user.language,
                meal_name=new_name,
                meal_description="",
                ingredients=Ingredients(ingredients=[Ingredient(volume=0, unit="", name="")]).model_dump(),
                steps=[],
            )
        )

        meal_info = MealInfo(
            status=previous_status,
            name=new_name,
            description="",
            calories=new_meal.calories,
            protein=new_meal.protein,
            carbs=new_meal.carbs,
            fat=new_meal.fat,
            weight=new_meal.weight,
            meal_id=new_meal.id,
        )

        if meal_info.status == MealStatus.EATEN:
            updated_macros = DailyMacrosSummaryCreate(
                day=day,
                calories=meal_info.calories - existing_meal.calories,
                protein=meal_info.protein - existing_meal.protein,
                carbs=meal_info.carbs - existing_meal.carbs,
                fat=meal_info.fat - existing_meal.fat,
            )
            await self._update_daily_macros_summary(user.id, updated_macros)

        await self.daily_summary_repo.remove_meal_from_summary(user.id, day, existing_meal.id)
        await self.daily_summary_repo.add_custom_meal(user.id, day, {new_meal.id: meal_info})
        return meal_info

    async def add_meal_details(self, meal_data: MealCreate):
        return await self.meal_repo.add_meal(meal_data)

    async def get_meal_details(self, meal_id: UUID):
        meal = await self.meal_repo.get_meal_by_id(meal_id)
        if not meal:
            logger.debug(f"Meal with id {meal_id} not found.")
            raise NotFoundInDatabaseException(f"Meal with id {meal_id} not found.")
        return meal

    async def _get_meal_calories(self, meal_id: UUID) -> int:
        calories = await self.meal_repo.get_meal_calories_by_id(meal_id)
        if calories is None:
            logger.debug(f"Meal with id {meal_id} not found.")
            raise NotFoundInDatabaseException(f"Meal with id {meal_id} not found.")
        return calories

    async def _get_meal_macros(self, meal_id: UUID):
        protein = await self.meal_repo.get_meal_protein_by_id(meal_id)
        fat = await self.meal_repo.get_meal_fat_by_id(meal_id)
        carbs = await self.meal_repo.get_meal_carbs_by_id(meal_id)

        if None in (protein, fat, carbs):
            logger.debug(f"Meal with id {meal_id} not found.")
            raise NotFoundInDatabaseException(f"Meal with id {meal_id} not found.")
        return {
            "protein": protein,
            "fat": fat,
            "carbs": carbs,
        }

    async def _update_daily_macros_summary(self, user_id: UUID, data: DailyMacrosSummaryCreate):
        user_daily_macros = await self.daily_summary_repo.get_daily_macros_summary(user_id, data.day)
        if not user_daily_macros:
            logger.debug(f"No plan for {data.day} for user {user_id}")
            raise NotFoundInDatabaseException("Plan for given user and day does not exist.")

        data.calories += user_daily_macros.calories
        data.protein += user_daily_macros.protein
        data.carbs += user_daily_macros.carbs
        data.fat += user_daily_macros.fat

        await self.daily_summary_repo.update_daily_macros_summary(user_id, data, data.day)
        return user_daily_macros

    async def _update_macros_after_status_change(
        self, user_id: UUID, day: date, meal_info: BasicMealInfo, status: MealStatus, previous_status: MealStatus
    ):
        multiplier = 0

        if status == MealStatus.EATEN and previous_status != MealStatus.EATEN:
            multiplier = 1
        elif status != MealStatus.EATEN and previous_status == MealStatus.EATEN:
            multiplier = -1

        if multiplier == 0:
            return

        calories = meal_info.calories
        protein = meal_info.protein
        carbs = meal_info.carbs
        fat = meal_info.fat
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
            calories=calories * multiplier,
            protein=protein * multiplier,
            carbs=carbs * multiplier,
            fat=fat * multiplier,
        )

        await self._update_daily_macros_summary(user_id, data)

    async def _update_next_meal_status(self, user_daily_meals: DailyMealsSummary):
        all_meal_links = user_daily_meals.daily_meals
        day = user_daily_meals.day
        user_id = user_daily_meals.user_id

        sorted_meals = MealType.sorted_meals()

        target_pending_meal_link = None

        for meal_type in sorted_meals:
            link_to_check = next((link for link in all_meal_links if link.meal.meal_type == meal_type), None)

            if not link_to_check:
                continue

            current_status = link_to_check.status

            if current_status == MealStatus.TO_EAT or current_status == MealStatus.PENDING:
                target_pending_meal_link = link_to_check
                break

        for link in all_meal_links:
            current_status = link.status
            new_status = current_status

            if link == target_pending_meal_link:
                if current_status != MealStatus.PENDING:
                    new_status = MealStatus.PENDING
                else:
                    continue
            elif current_status == MealStatus.PENDING:
                new_status = MealStatus.TO_EAT
            elif current_status == MealStatus.TO_EAT and link != target_pending_meal_link:
                continue

            if new_status != current_status:
                link.status = new_status.value
                await self.daily_summary_repo.update_meal_status(user_id, day, link.meal_id, new_status)
