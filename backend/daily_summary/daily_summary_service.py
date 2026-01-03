from datetime import date
from typing import Dict, List, Type, Union
from uuid import UUID

from backend.core.logger import logger
from backend.core.not_found_in_database_exception import NotFoundInDatabaseException
from backend.daily_summary.composed_meal_items_service import ComposedMealItemsService
from backend.daily_summary.daily_summary_mapper import DailySummaryMapper
from backend.daily_summary.enums.meal_status import MealStatus
from backend.daily_summary.repositories.daily_summary_repository import DailySummaryRepository
from backend.daily_summary.repositories.last_generated_meals_repository import LastGeneratedMealsRepository
from backend.daily_summary.repositories.meal_type_daily_summary_repository import MealTypeDailySummaryRepository
from backend.daily_summary.schemas import (
    BasicMealInfo,
    ComposedMealUpdateRequest,
    DailyMacrosSummaryCreate,
    DailyMealsCreate,
    DailySummaryDTO,
    Macros,
    Meal,
    MealInfoUpdateRequest,
    MealInfoWithIconPath,
    MealTypeDailySummaryBase,
    RemoveMealRequest,
    RemoveMealResponse,
)
from backend.meals.enums.meal_type import MealType
from backend.meals.meal_gateway import MealGateway
from backend.meals.repositories.meal_repository import MealRepository
from backend.models import ComposedMealItem, User
from backend.user_details.user_details_gateway import UserDetailsGateway


class DailySummaryService:
    def __init__(
        self,
        summary_repository: DailySummaryRepository,
        meal_type_daily_summary_repository: MealTypeDailySummaryRepository,
        meal_repository: MealRepository,
        last_generated_meals_repository: LastGeneratedMealsRepository,
        composed_meal_items_service: ComposedMealItemsService,
        meal_gateway: MealGateway,
        user_details_gateway: UserDetailsGateway,
    ):
        self.daily_summary_repository = summary_repository
        self.meal_type_daily_summary_repository = meal_type_daily_summary_repository
        self.meal_repository = meal_repository
        self.last_generated_meals_repo = last_generated_meals_repository
        self.composed_meal_items_service = composed_meal_items_service
        self.meal_gateway = meal_gateway
        self.user_details_gateway = user_details_gateway

    async def get_daily_summary(self, user: Type[User], day: date):
        daily_meals = await self.daily_summary_repository.get_daily_summary(user.id, day)
        if not daily_meals:
            logger.debug(f"No daily meals for {day} for user {user.id}")
            raise NotFoundInDatabaseException("Plan for given user and day does not exist.")

        meals_dict = await self.fetch_daily_meals(daily_meals, user)
        generated_meals_dict = await self.fetch_generated_meals(daily_meals, user)
        macros_summary = await self.get_daily_macros_summary(user.id, day)
        last_diet_prediction = await self.user_details_gateway.get_date_of_last_update_user_calories_prediction(user)
        last_user_details = await self.user_details_gateway.get_date_of_last_update_user_details(user)

        return DailySummaryDTO(
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
            meal_items_info: List[MealInfoWithIconPath] = []

            for item in link.meal_items:
                meal = item.meal
                if meal and item.is_active:
                    recipe = (
                        None
                        if not meal.is_generated
                        else await self.meal_gateway.get_meal_recipe_by_meal_and_language_safe(meal.id, user.language)
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
                            unit_weight=int(meal.weight),
                            planned_calories=item.planned_calories,
                            planned_protein=item.planned_protein,
                            planned_carbs=item.planned_carbs,
                            planned_fat=item.planned_fat,
                            planned_weight=item.planned_weight,
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
                    unit_weight=int(meal.weight),
                    planned_weight=item.planned_weight,
                    planned_calories=item.planned_calories,
                    planned_protein=item.planned_protein,
                    planned_carbs=item.planned_carbs,
                    planned_fat=item.planned_fat,
                )

    async def add_daily_meals(self, daily_meals_data: DailyMealsCreate, user_id: UUID):
        daily_meals = await self.daily_summary_repository.get_daily_meals_summary_with_recipes(
            user_id, daily_meals_data.day
        )
        if daily_meals:
            await self.daily_summary_repository.remove_daily_meals_summary(daily_meals.id)

        await self.daily_summary_repository.add_daily_meals_summary(daily_meals_data, user_id)

        daily_meals = await self.daily_summary_repository.get_daily_meals_summary_with_recipes(
            user_id, daily_meals_data.day
        )
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
                    unit_weight=int(meal.weight),
                    planned_weight=int(meal.weight),
                    planned_calories=meal.calories,
                    planned_protein=meal.protein,
                    planned_fat=meal.fat,
                    planned_carbs=meal.carbs,
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
        print(day)
        daily_meals = await self.daily_summary_repository.get_daily_meals_summary_with_recipes(user.id, day)
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
        daily_macros_summary = await self.daily_summary_repository.get_daily_macros_summary(user_id, data.day)
        if daily_macros_summary:
            return await self.daily_summary_repository.update_daily_macros_summary(user_id, data, data.day)
        return await self.daily_summary_repository.add_daily_macros_summary(data, user_id)

    async def get_daily_macros_summary(self, user_id: UUID, day: date):
        macros_summary = await self.daily_summary_repository.get_daily_macros_summary(user_id, day)
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

        daily_meal_type_summary_with_items = DailySummaryMapper.map_daily_meal_types_summary_with_items(
            await self.daily_summary_repository.get_all_daily_meal_types_with_items(user.id, day)
        )
        if not daily_meal_type_summary_with_items:
            logger.debug(f"No plan for {day} for user {user.id}")
            raise NotFoundInDatabaseException("Plan for given user and day does not exist.")

        processing_meal_type_summary = daily_meal_type_summary_with_items.map_meal_type_daily_summaries.get(
            meal_type, None
        )
        if not processing_meal_type_summary:
            logger.debug(f"No planned meal type for {day} for user {user.id}")
            raise NotFoundInDatabaseException("Plan for given user and day does not exist.")

        previous_status = processing_meal_type_summary.status

        active_meals = [m for m in processing_meal_type_summary.composed_meal_items if m and m.is_active]

        meal_macros = Macros(
            calories=int(sum(m.planned_calories for m in active_meals)),
            protein=float(sum(m.planned_protein for m in active_meals)),
            carbs=float(sum(m.planned_carbs for m in active_meals)),
            fat=float(sum(m.planned_fat for m in active_meals)),
        )

        updated_meal_type_daily_summary = await self.meal_type_daily_summary_repository.update_meal_type_status(
            processing_meal_type_summary.daily_summary_id, new_status
        )
        if updated_meal_type_daily_summary:
            await self._update_macros_after_status_change(user.id, meal_macros, day, new_status, previous_status)

            map_meal_type_daily_summaries = daily_meal_type_summary_with_items.map_meal_type_daily_summaries
            processing_meal_type_summary.status = updated_meal_type_daily_summary.status

            await self._update_next_meals_status(map_meal_type_daily_summaries)

            return meal_macros
        return None

    async def edit_meal(self, user: Type[User], update_meal_request: ComposedMealUpdateRequest) -> ComposedMealItem:
        return await self.composed_meal_items_service.edit_meal(user, update_meal_request)

    async def add_custom_meal(self, user: Type[User], custom_meal: ComposedMealUpdateRequest) -> ComposedMealItem:
        return await self.composed_meal_items_service.add_composed_meal(user, custom_meal)

    async def remove_meal_from_summary(self, user: Type[User], meal_to_remove: RemoveMealRequest):
        day = meal_to_remove.day
        meal_type = meal_to_remove.meal_type
        meal_id = meal_to_remove.meal_id

        meal_type_daily_summary = DailySummaryMapper.map_to_daily_meal_type(
            await self.daily_summary_repository.get_daily_meal_type_summary(user.id, day, meal_type)
        )
        if not meal_type_daily_summary or not meal_type_daily_summary.daily_summary_id:
            logger.debug(f"No plan for {day} for user {user.id}")
            raise NotFoundInDatabaseException("Plan for given user and day does not exist.")

        composed_meal_item, removed = await self.composed_meal_items_service.remove_composed_meal(user.id, meal_id)

        if not removed:
            logger.debug(f"Meal with id {meal_id} does not exist for type {meal_type}, user {user.id} and day {day}")
            raise NotFoundInDatabaseException("Selected meal not assigned to selected meal type.")

        if meal_type_daily_summary.meal_type_details.status == MealStatus.EATEN:
            macros_to_subtract = DailyMacrosSummaryCreate(
                day=day,
                calories=(-1) * composed_meal_item.planned_calories,
                protein=(-1) * composed_meal_item.planned_protein,
                carbs=(-1) * composed_meal_item.planned_carbs,
                fat=(-1) * composed_meal_item.planned_fat,
            )

            updated_macros = await self._update_daily_macros_summary(user.id, macros_to_subtract)
            if not updated_macros:
                logger.debug(f"Failed to update macros summary after removing meal {meal_id}")
                raise NotFoundInDatabaseException("Failed to update macros summary after removing meal.")

        return RemoveMealResponse(day=day, meal_type=meal_type, meal_id=meal_id, success=True)

    async def get_meal_details(self, meal_id: UUID):
        meal = await self.meal_gateway.get_meal_by_id(meal_id)
        if not meal:
            logger.debug(f"Meal with id {meal_id} not found.")
            raise NotFoundInDatabaseException(f"Meal with id {meal_id} not found.")
        return meal

    @staticmethod
    def _calculate_planned_value(
        macro_value: Union[int, float], base_weight: int, planned_weight: int, is_int: bool = False
    ) -> Union[int, float]:
        if not macro_value or not base_weight or base_weight <= 0:
            return 0 if is_int else 0.0

        scale_factor = planned_weight / base_weight
        result = macro_value * scale_factor

        if is_int:
            return int(result)
        else:
            return round(result, 2)

    async def _get_meal_calories(self, meal_id: UUID) -> int:
        calories = await self.meal_repository.get_meal_calories_by_id(meal_id)
        if calories is None:
            logger.debug(f"Meal with id {meal_id} not found.")
            raise NotFoundInDatabaseException(f"Meal with id {meal_id} not found.")
        return calories

    async def _get_meal_macros(self, meal_id: UUID):
        protein = await self.meal_repository.get_meal_protein_by_id(meal_id)
        fat = await self.meal_repository.get_meal_fat_by_id(meal_id)
        carbs = await self.meal_repository.get_meal_carbs_by_id(meal_id)

        if None in (protein, fat, carbs):
            logger.debug(f"Meal with id {meal_id} not found.")
            raise NotFoundInDatabaseException(f"Meal with id {meal_id} not found.")
        return {
            "protein": protein,
            "fat": fat,
            "carbs": carbs,
        }

    async def _update_daily_macros_summary(self, user_id: UUID, data: DailyMacrosSummaryCreate):
        user_daily_macros = await self.daily_summary_repository.get_daily_macros_summary(user_id, data.day)
        if not user_daily_macros:
            logger.debug(f"No plan for {data.day} for user {user_id}")
            raise NotFoundInDatabaseException("Plan for given user and day does not exist.")

        data.calories += user_daily_macros.calories
        data.protein += user_daily_macros.protein
        data.carbs += user_daily_macros.carbs
        data.fat += user_daily_macros.fat

        await self.daily_summary_repository.update_daily_macros_summary(user_id, data, data.day)
        return user_daily_macros

    async def _update_macros_after_status_change(
        self, user_id: UUID, macros: Macros, day: date, status: MealStatus, previous_status: MealStatus
    ):
        multiplier = 0

        if status == MealStatus.EATEN and previous_status != MealStatus.EATEN:
            multiplier = 1
        elif status != MealStatus.EATEN and previous_status == MealStatus.EATEN:
            multiplier = -1

        if multiplier == 0:
            return

        data = DailyMacrosSummaryCreate(
            day=day,
            calories=macros.calories * multiplier,
            protein=macros.protein * multiplier,
            carbs=macros.carbs * multiplier,
            fat=macros.fat * multiplier,
        )

        await self._update_daily_macros_summary(user_id, data)

    async def _update_next_meals_status(self, map_meal_type_daily_summaries: dict[MealType, MealTypeDailySummaryBase]):
        target_pending_meal = await self._find_target_pending_meal(map_meal_type_daily_summaries)

        if target_pending_meal:
            target_pending_meal.status = MealStatus.PENDING
            await self.meal_type_daily_summary_repository.update_meal_type_status(
                target_pending_meal.daily_summary_id, MealStatus.PENDING
            )

        for link in map_meal_type_daily_summaries.values():
            if link.status == MealStatus.PENDING and link != target_pending_meal:
                link.status = MealStatus.TO_EAT
                await self.meal_type_daily_summary_repository.update_meal_type_status(
                    link.daily_summary_id, MealStatus.TO_EAT
                )

    @staticmethod
    async def _find_target_pending_meal(map_meal_type_daily_summaries):
        sorted_meals = MealType.sorted_meals()
        for meal_type in sorted_meals:
            current_meal_type_summary = map_meal_type_daily_summaries.get(meal_type)
            current_status = current_meal_type_summary.status

            if current_status == MealStatus.TO_EAT or current_status == MealStatus.PENDING:
                return current_meal_type_summary

    @staticmethod
    def _find_meal_slot(daily_summary, meal_type: MealType, user_id: UUID, day: date):
        slot = next((s for s in daily_summary.daily_meals if s.meal_type == meal_type), None)

        if not slot:
            logger.debug(f"Meal does not exist in {user_id} plan for {day}")
            raise NotFoundInDatabaseException("Meal does not exist in user's plan for the given day.")

        if not slot.meal_items:
            logger.debug(f"No composed meals assigned to {meal_type} for {day}.")
            raise NotFoundInDatabaseException("No composed meals assigned to this meal slot.")

        return slot
