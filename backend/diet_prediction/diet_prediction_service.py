from backend.core.not_found_in_database_exception import NotFoundInDatabaseException
from backend.diet_prediction.enums.meal_type import MealType
from backend.diet_prediction.meal_icons_repository import MealIconsRepository
from backend.models import MealIcon


class MealIconsService:
    def __init__(
        self,
        meal_icons_repository: MealIconsRepository,
    ):
        self.meal_icons_repository = meal_icons_repository

    async def get_meal_icon(self, meal_type: MealType) -> MealIcon:
        meal_icon = await self.meal_icons_repository.get_meal_icon_by_type(meal_type)
        if not meal_icon:
            raise NotFoundInDatabaseException("Meal icon not found")

        return meal_icon
