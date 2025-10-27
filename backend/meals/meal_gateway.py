from fastapi import Depends

from backend.meals.dependencies import get_meal_service
from backend.meals.meal_service import MealService
from backend.models import Meal, MealRecipe


class MealGateway:
    def __init__(
            self, meal_service: MealService,
    ):
        self.meal_service = meal_service

    async def add_meal(self, meal: Meal) -> Meal:
        return await self.meal_service.add_meal(meal)

    async def add_meal_recipe(self, meal_recipe: MealRecipe) -> MealRecipe:
        return await self.meal_service.add_meal_recipe(meal_recipe)

def get_meal_gateway(
        meal_service: MealService = Depends(get_meal_service),
) -> MealGateway:
    return MealGateway(meal_service)
