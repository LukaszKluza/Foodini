from uuid import UUID

from fastapi import Depends

from backend.meals.dependencies import get_meal_service
from backend.meals.enums.meal_type import MealType
from backend.meals.meal_service import MealService
from backend.meals.schemas import MealRecipeResponse
from backend.models import Meal, MealRecipe
from backend.users.enums.language import Language


class MealGateway:
    def __init__(
        self,
        meal_service: MealService,
    ):
        self.meal_service = meal_service

    async def add_meal(self, meal: Meal) -> Meal:
        return await self.meal_service.add_meal(meal)

    async def add_meal_recipe(self, meal_recipe: MealRecipe) -> MealRecipe:
        return await self.meal_service.add_meal_recipe(meal_recipe)

    async def get_meal_recipe_by_meal_and_language_safe(self, meal_id: UUID, language: Language) -> MealRecipeResponse:
        return await self.meal_service.get_meal_recipe_by_meal_and_language_safe(meal_id, language)

    async def get_meal_icon_id(self, meal_type: MealType) -> UUID:
        return await self.meal_service.get_meal_icon_id(meal_type)

    async def get_meal_icon_path_by_id(self, meal_id: UUID) -> str:
        return await self.meal_service.get_meal_icon_path_by_id(meal_id)


async def get_meal_gateway(
    meal_service: MealService = Depends(get_meal_service),
) -> MealGateway:
    return MealGateway(meal_service)
