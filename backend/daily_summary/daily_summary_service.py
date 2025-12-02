from datetime import date
from typing import Dict, List, Type
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
    Meal,
    MealInfo,
    MealInfoUpdateRequest,
    MealInfoWithIconPath,
    RemoveMealRequest,
    RemoveMealResponse,
)
from backend.meals.enums.meal_type import MealType
from backend.meals.meal_gateway import MealGateway
from backend.meals.repositories.meal_repository import MealRepository
from backend.meals.schemas import MealCreate
from backend.models import DailyMealsSummary, User
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

        meals_dict = await self.fetch_daily_meals(daily_meals, user)
        generated_meals_dict = await self.fetch_generated_meals(daily_meals, user)
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
            is_out_dated=await self.is_diet_out_dated(daily_meals, last_diet_prediction, last_user_details),
            generated_meals=generated_meals_dict,
        )

    @classmethod
    async def is_diet_out_dated(cls, daily_meals, last_diet_prediction, last_user_details):
        return (
            daily_meals.updated_at <= last_diet_prediction
            or daily_meals.updated_at <= last_user_details
            and daily_meals.day >= date.today()
        )

    async def fetch_daily_meals(self, daily_meals, user):
        meals_dict: Dict[MealType, Meal] = {}
        for link in daily_meals.daily_meals:
            if link.is_active:
                meal_items_info: List[MealInfoWithIconPath] = []

                for item in link.meal_items:
                    meal = item.meal
                    if meal:
                        recipe = (
                            None
                            if not meal.is_generated
                            else await self.meal_gateway.get_meal_recipe_by_meal_and_language_safe(
                                meal.id, user.language
                            )
                        )

                        meal_items_info.append(
                            MealInfoWithIconPath(
                                meal_id=meal.id,
                                name=recipe.meal_name if recipe else meal.meal_name,
                                description=recipe.meal_description if recipe else None,
                                explanation=recipe.meal_explanation if recipe else None,
                                icon_path=await self.meal_gateway.get_meal_icon_path_by_id(meal.icon_id),
                                calories=int(meal.calories),
                                protein=float(meal.protein),
                                carbs=float(meal.carbs),
                                fat=float(meal.fat),
                                weight=item.weight_eaten if item.weight_eaten is not None else int(meal.weight),
                            )
                        )

                meals_dict[link.meal_type] = Meal(meal_items=meal_items_info, status=link.status)
        return meals_dict

    async def fetch_generated_meals(self, daily_meals, user):
        meals_dict: Dict[MealType, MealInfoWithIconPath] = {}
        for link in daily_meals.daily_meals:
            meal_items_info = await self.find_generated_meal(link, user)
            if meal_items_info:
                meals_dict[link.meal_type] = meal_items_info
        return meals_dict

    async def find_generated_meal(self, link, user):
        for item in link.meal_items:
            meal = item.meal
            if meal and meal.is_generated:
                recipe = await self.meal_gateway.get_meal_recipe_by_meal_and_language_safe(meal.id, user.language)

                return MealInfoWithIconPath(
                    meal_id=meal.id,
                    status=link.status,
                    name=recipe.meal_name,
                    description=recipe.meal_description,
                    explanation=recipe.meal_explanation,
                    icon_path=await self.meal_gateway.get_meal_icon_path_by_id(meal.icon_id),
                    calories=int(meal.calories),
                    protein=float(meal.protein),
                    carbs=float(meal.carbs),
                    fat=float(meal.fat),
                    weight=item.weight_eaten if item.weight_eaten is not None else int(meal.weight),
                )

    async def add_daily_meals(self, daily_meals_data: DailyMealsCreate, user_id: UUID):
        daily_meals = await self.daily_summary_repo.get_daily_meals_summary(user_id, daily_meals_data.day)
        if daily_meals:
            await self.daily_summary_repo.remove_daily_meals_summary(daily_meals.id)

        await self.daily_summary_repo.add_daily_meals_summary(daily_meals_data, user_id)

        daily_meals = await self.daily_summary_repo.get_daily_meals_summary(user_id, daily_meals_data.day)
        meals_dict: Dict[MealType, List[BasicMealInfo]] = {}

        for link in daily_meals.daily_meals:
            meal_items_info: List[BasicMealInfo] = []

            for item in link.meal_items:
                meal = item.meal

                basic_info = BasicMealInfo(
                    meal_id=meal.id,
                    status=link.status,
                    calories=int(meal.calories),
                    protein=float(meal.protein),
                    carbs=float(meal.carbs),
                    fat=float(meal.fat),
                    weight=item.weight_eaten if item.weight_eaten is not None else meal.weight,
                )

                meal_items_info.append(basic_info)

            meals_dict[link.meal_type] = meal_items_info

        return DailyMealsCreate(
            day=daily_meals.day,
            meals=meals_dict,
            target_calories=daily_meals.target_calories,
            target_protein=float(daily_meals.target_protein),
            target_carbs=float(daily_meals.target_carbs),
            target_fat=float(daily_meals.target_fat),
        )

    # TODO Simplify and fix it
    async def get_daily_meals(self, user: Type[User], day: date):
        daily_meals = await self.daily_summary_repo.get_daily_meals_summary(user.id, day)
        if not daily_meals:
            logger.debug(f"No plan for {day} for user {user.id}")
            raise NotFoundInDatabaseException("Plan for given user and day does not exist.")

        meals_dict = await self.fetch_daily_meals(daily_meals, user)
        flatten_meals_dict = {}

        for meal_type, meal in meals_dict.items():
            flatten_meals_dict[meal_type] = meal.meal_items

        return DailyMealsCreate(
            day=daily_meals.day,
            meals=flatten_meals_dict,
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
        meal_type = update_meal_data.meal_type
        new_status = update_meal_data.status

        user_daily_meals = await self.daily_summary_repo.get_daily_meals_summary(user.id, day)
        if not user_daily_meals:
            logger.debug(f"No plan for {day} for user {user.id}")
            raise NotFoundInDatabaseException("Plan for given user and day does not exist.")

        slot = self._find_meal_slot(user_daily_meals, meal_type, user.id, day)

        previous_status = slot.status

        total_calories = 0
        total_protein = 0
        total_carbs = 0
        total_fat = 0

        for item in slot.meal_items:
            meal = item.meal
            if not meal:
                continue
            total_calories += meal.calories
            total_protein += meal.protein
            total_carbs += meal.carbs
            total_fat += meal.fat

        meal_info = BasicMealInfo(
            status=new_status,
            calories=int(total_calories),
            protein=float(total_protein),
            carbs=float(total_carbs),
            fat=float(total_fat),
            meal_id=slot.meal_items[0].meal_id,
            weight=slot.meal_items[0].meal.weight,
            # Weight doesnt matter. We can think of optional weight here and in model on front
        )

        await self.daily_summary_repo.update_meal_status(user.id, day, meal_type, new_status)
        await self._update_macros_after_status_change(user.id, day, meal_info, new_status, previous_status)
        await self._update_next_meal_status(user_daily_meals)

        return meal_info

    # ruff: noqa: C901
    async def add_custom_meal(self, user: Type[User], custom_meal: CustomMealUpdateRequest):
        day = custom_meal.day
        daily_meals = await self.daily_summary_repo.get_daily_summary(user.id, day, user.language)
        if not daily_meals:
            logger.debug(f"No plan for {day} for user {user.id}")
            raise NotFoundInDatabaseException("Plan for given user and day does not exist.")

        daily_meals.daily_meals = list(daily_meals.daily_meals)

        existing_link = None
        existing_item = None

        if custom_meal.meal_id:
            for link in daily_meals.daily_meals:
                for item in link.meal_items:
                    if item.meal_id == custom_meal.meal_id:
                        existing_link = link
                        existing_item = item
                        break
                if existing_link:
                    break

            if not existing_item:
                raise NotFoundInDatabaseException(f"No meal of id {custom_meal.meal_id} for this day.")

            previous_status = MealStatus(existing_link.status)
            existing_meal = existing_item.meal

        else:
            existing_link = next(
                (link for link in daily_meals.daily_meals if link.meal_type == custom_meal.meal_type),
                None,
            )

            if not existing_link:
                logger.debug(f"No meal type {custom_meal.meal_type} for {day} for user {user.id}")
                raise NotFoundInDatabaseException(f"No meal type {custom_meal.meal_type} found for this day.")

            previous_status = MealStatus(existing_link.status)
            existing_meal = None

        new_meal_name = custom_meal.custom_name or (existing_meal.meal_name if existing_meal else "Custom Meal")

        new_meal = MealCreate(
            meal_name=new_meal_name,
            meal_type=existing_link.meal_type,
            icon_id=existing_meal.icon_id if existing_meal else None,
            calories=custom_meal.custom_calories or (existing_meal.calories if existing_meal else 0),
            protein=custom_meal.custom_protein or (existing_meal.protein if existing_meal else 0),
            carbs=custom_meal.custom_carbs or (existing_meal.carbs if existing_meal else 0),
            fat=custom_meal.custom_fat or (existing_meal.fat if existing_meal else 0),
            weight=custom_meal.custom_weight,
            is_generated=existing_meal.is_generated if existing_meal else False,
        )

        if existing_meal:
            new_meal = await self.meal_repo.update_meal_by_id(existing_meal.id, new_meal)
        else:
            new_meal = await self.meal_repo.add_meal(new_meal)

        if not new_meal:
            logger.debug("No existing meal for update in database or failure in adding new meal.")
            raise NotFoundInDatabaseException("Error while adding new meal/editing existing one in database.")

        meal_info = MealInfo(
            status=previous_status,
            name=new_meal_name,
            description="",
            calories=new_meal.calories,
            protein=new_meal.protein,
            carbs=new_meal.carbs,
            fat=new_meal.fat,
            weight=custom_meal.eaten_weight or new_meal.weight,
            meal_id=new_meal.id,
        )

        if previous_status == MealStatus.EATEN:
            new_c = int(new_meal.calories or 0)
            new_p = float(new_meal.protein or 0)
            new_cb = float(new_meal.carbs or 0)
            new_f = float(new_meal.fat or 0)

            if existing_meal and existing_item:
                old_c = int(existing_meal.calories or 0)
                old_p = float(existing_meal.protein or 0)
                old_cb = float(existing_meal.carbs or 0)
                old_f = float(existing_meal.fat or 0)
                delta = DailyMacrosSummaryCreate(
                    day=day,
                    calories=new_c - old_c,
                    protein=new_p - old_p,
                    carbs=new_cb - old_cb,
                    fat=new_f - old_f,
                )
            else:
                delta = DailyMacrosSummaryCreate(day=day, calories=new_c, protein=new_p, carbs=new_cb, fat=new_f)

            await self._update_daily_macros_summary(user.id, delta)

        if existing_item:
            await self.daily_summary_repo.remove_meal_from_summary(user.id, day, existing_item.meal_id)

        await self.daily_summary_repo.add_custom_meal(user.id, day, custom_meal.meal_type, {new_meal.id: meal_info})

        return meal_info

    async def remove_meal_from_summary(self, user: Type[User], meal_to_remove: RemoveMealRequest):
        day = meal_to_remove.day
        meal_type = meal_to_remove.meal_type
        meal_id = meal_to_remove.meal_id

        user_daily_meals = await self.daily_summary_repo.get_daily_meals_summary(user.id, day)
        if not user_daily_meals:
            logger.debug(f"No plan for {day} for user {user.id}")
            raise NotFoundInDatabaseException("Plan for given user and day does not exist.")

        slot = self._find_meal_slot(user_daily_meals, meal_type, user.id, day)

        removed = await self.daily_summary_repo.remove_meal_from_summary(user.id, day, meal_type, meal_id)
        if not removed:
            logger.debug(f"Meal with id {meal_id} does not exist for type {meal_type}, user {user.id} and day {day}")
            raise NotFoundInDatabaseException("Selected meal not assigned to selected meal type.")

        if slot.status == MealStatus.EATEN:
            calories = await self._get_meal_calories(meal_id)
            macros = await self._get_meal_macros(meal_id)

            macros_to_subtract = DailyMacrosSummaryCreate(
                day=day,
                calories=(-1) * calories,
                protein=(-1) * macros["protein"],
                carbs=(-1) * macros["carbs"],
                fat=(-1) * macros["fat"],
            )

            updated_macros = await self._update_daily_macros_summary(user.id, macros_to_subtract)
            if not updated_macros:
                logger.debug(f"Failed to update macros summary after removing meal {meal_id}")
                raise NotFoundInDatabaseException("Failed to update macros summary after removing meal.")

        return RemoveMealResponse(day=day, meal_type=meal_type, meal_id=meal_id, success=True)

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
            link_to_check = next((link for link in all_meal_links if link.meal_type == meal_type), None)

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
                await self.daily_summary_repo.update_meal_status(user_id, day, link.meal_type, new_status)

    def _find_meal_slot(self, daily_summary, meal_type: MealType, user_id: UUID, day: date):
        slot = next((s for s in daily_summary.daily_meals if s.meal_type == meal_type), None)

        if not slot:
            logger.debug(f"Meal does not exist in {user_id} plan for {day}")
            raise NotFoundInDatabaseException("Meal does not exist in user's plan for the given day.")

        if not slot.meal_items:
            logger.debug(f"No composed meals assigned to {meal_type} for {day}.")
            raise NotFoundInDatabaseException("No composed meals assigned to this meal slot.")

        return slot
