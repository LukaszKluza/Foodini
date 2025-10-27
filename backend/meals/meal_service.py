from typing import List

from backend.core.not_found_in_database_exception import NotFoundInDatabaseException
from backend.meals.enums.meal_type import MealType
from backend.meals.repositories.meal_icons_repository import MealIconsRepository
from backend.meals.repositories.meal_recipes_repository import MealRecipesRepository
from backend.models import MealIcon, MealRecipe, Meal
from backend.users.enums.language import Language


class MealService:
    def __init__(
        self,
        meal_icons_repository: MealIconsRepository,
        meal_recipes_repository: MealRecipesRepository,
    ):
        self.meal_icons_repository = meal_icons_repository
        self.meal_recipes_repository = meal_recipes_repository

    async def get_meal_icon(self, meal_type: MealType) -> MealIcon:
        meal_icon = await self.meal_icons_repository.get_meal_icon_by_type(meal_type)
        return await self.validate_response(meal_icon, "Meal icon not found")

    async def add_meal(self, meal: Meal) -> Meal:
        return await self.meal_recipes_repository.add_meal(meal)

    async def add_meal_recipe(self, meal_recipe: MealRecipe) -> MealRecipe:
        return await self.meal_recipes_repository.add_meal_recipe(meal_recipe)

    async def get_meal_recipe_by_recipe_id(self, recipe_id: int) -> MealRecipe:
        meal_recipe = await self.meal_recipes_repository.get_meal_recipe_by_recipe_id(recipe_id)
        return await self.validate_response(meal_recipe)

    async def get_meal_recipes_by_meal_recipe_id(self, meal_id: int) -> List[MealRecipe]:
        meal_recipes = await self.meal_recipes_repository.get_meal_recipe_by_recipe_id(meal_id)
        return await self.validate_response(meal_recipes, "Meal recipes not found")

    async def get_meal_recipe_by_meal_recipe_id_and_language(self, meal_id: int, language: Language) -> MealRecipe:
        meal_recipe = await self.meal_recipes_repository.get_meal_recipe_by_meal_id_and_language(meal_id, language)
        return await self.validate_response(meal_recipe)

    @classmethod
    async def validate_response(cls, response, message: str = "Meal recipe not found"):
        if not response:
            raise NotFoundInDatabaseException(message)
        return response
