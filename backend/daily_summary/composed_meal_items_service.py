from typing import Type, Union
from uuid import UUID

from backend.core.logger import logger
from backend.core.not_found_in_database_exception import NotFoundInDatabaseException
from backend.daily_summary.daily_summary_mapper import DailySummaryMapper
from backend.daily_summary.enums.meal_status import MealStatus
from backend.daily_summary.repositories.composed_meal_items_repository import ComposedMealItemsRepository
from backend.daily_summary.repositories.daily_summary_repository import DailySummaryRepository
from backend.daily_summary.schemas import (
    ComposedMealItemUpdateEntity,
    ComposedMealUpdateRequest,
    DailyMacrosSummaryCreate,
)
from backend.meals.meal_gateway import MealGateway
from backend.meals.schemas import MealCreate
from backend.models import ComposedMealItem, User


class ComposedMealItemsService:
    def __init__(
        self,
        summary_repository: DailySummaryRepository,
        composed_meal_items_repository: ComposedMealItemsRepository,
        meal_gateway: MealGateway,
    ):
        self.daily_summary_repository = summary_repository
        self.composed_meal_items_repository = composed_meal_items_repository
        self.meal_gateway = meal_gateway

    async def edit_meal(self, user: Type[User], update_meal_request: ComposedMealUpdateRequest) -> ComposedMealItem:
        day = update_meal_request.day
        meal_id = update_meal_request.meal_id
        old_composed_meal = await self._get_composed_meal_item_with_summary_and_origin_meal(user.id, meal_id)

        origin_meal = old_composed_meal.meal
        if not origin_meal:
            raise NotFoundInDatabaseException(f"No origin meal of id {update_meal_request.meal_id} for this day.")

        meal_type_daily_summary = old_composed_meal.daily_meal
        if not meal_type_daily_summary:
            raise NotFoundInDatabaseException(
                f"No meal type daily summary for composed meal of id {update_meal_request.meal_id} for this day."
            )

        composed_meal_item = ComposedMealItemUpdateEntity(
            planned_weight=update_meal_request.custom_weight,
            planned_calories=self._calculate_planned_value(
                origin_meal.calories, origin_meal.weight, update_meal_request.custom_weight, is_int=True
            ),
            planned_protein=self._calculate_planned_value(
                origin_meal.protein, origin_meal.weight, update_meal_request.custom_weight
            ),
            planned_carbs=self._calculate_planned_value(
                origin_meal.carbs, origin_meal.weight, update_meal_request.custom_weight
            ),
            planned_fat=self._calculate_planned_value(
                origin_meal.fat, origin_meal.weight, update_meal_request.custom_weight
            ),
        )

        if meal_type_daily_summary.status == MealStatus.EATEN:
            delta = DailyMacrosSummaryCreate(
                day=day,
                calories=composed_meal_item.planned_calories - old_composed_meal.planned_calories,
                protein=composed_meal_item.planned_protein - old_composed_meal.planned_protein,
                carbs=composed_meal_item.planned_carbs - old_composed_meal.planned_carbs,
                fat=composed_meal_item.planned_fat - old_composed_meal.planned_fat,
            )
            await self._update_daily_macros_summary(user.id, delta)

        return await self.composed_meal_items_repository.update_composed_meal_item(
            old_composed_meal.id, composed_meal_item
        )

    async def add_composed_meal(
        self, user: Type[User], new_composed_meal: ComposedMealUpdateRequest
    ) -> ComposedMealItem:
        day = new_composed_meal.day
        meal_type_daily_summary = DailySummaryMapper.map_to_daily_meal_type(
            await self.daily_summary_repository.get_daily_meal_type_summary(user.id, day, new_composed_meal.meal_type)
        )
        if not meal_type_daily_summary or meal_type_daily_summary.meal_daily_summary_id is None:
            logger.debug(f"No plan for {day} for user {user.id}")
            raise NotFoundInDatabaseException("Plan for given user and day does not exist.")

        new_meal = await self.meal_gateway.add_meal(MealCreate.from_custom_meal_request(new_composed_meal))

        if not new_meal:
            logger.debug("No existing meal for update in database or failure in adding new meal.")
            raise NotFoundInDatabaseException("Error while adding new meal into database.")

        composed_meal_item = ComposedMealItem(
            meal_daily_summary_id=meal_type_daily_summary.meal_daily_summary_id,
            meal_id=new_meal.id,
            planned_weight=new_composed_meal.custom_weight,
            planned_calories=self._calculate_planned_value(
                new_meal.calories, new_meal.weight, new_composed_meal.custom_weight, is_int=True
            ),
            planned_protein=self._calculate_planned_value(
                new_meal.protein, new_meal.weight, new_composed_meal.custom_weight
            ),
            planned_carbs=self._calculate_planned_value(
                new_meal.carbs, new_meal.weight, new_composed_meal.custom_weight
            ),
            planned_fat=self._calculate_planned_value(new_meal.fat, new_meal.weight, new_composed_meal.custom_weight),
        )

        if meal_type_daily_summary.status == MealStatus.EATEN:
            delta = DailyMacrosSummaryCreate(
                day=day,
                calories=composed_meal_item.planned_calories,
                protein=composed_meal_item.planned_protein,
                carbs=composed_meal_item.planned_carbs,
                fat=composed_meal_item.planned_fat,
            )
            await self._update_daily_macros_summary(user.id, delta)

        await self.composed_meal_items_repository.add_composed_meal_item(composed_meal_item)
        return composed_meal_item

    async def remove_composed_meal(self, user_id: UUID, meal_id: UUID):
        composed_meal_item = await self._get_composed_meal_item_with_summary_and_origin_meal(user_id, meal_id)

        if composed_meal_item.meal.is_generated:
            removed = await self.composed_meal_items_repository.remove_meal_from_summary(composed_meal_item.id)
        else:
            removed = await self.meal_gateway.delete_meal_by_id(meal_id)
        return composed_meal_item, removed

    async def _get_composed_meal_item_with_summary_and_origin_meal(self, user_id: UUID, meal_id: UUID):
        composed_meal = await self.composed_meal_items_repository.get_composed_meal_item_with_summary_and_origin_meal(
            user_id, meal_id
        )
        if not composed_meal:
            logger.debug(f"No composed meal {meal_id} for user {user_id}")
            raise NotFoundInDatabaseException("Composed meal for given user does not exist.")
        return composed_meal

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
