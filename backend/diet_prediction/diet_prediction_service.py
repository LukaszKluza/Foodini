from typing import List

from backend.core.not_found_in_database_exception import NotFoundInDatabaseException
from backend.diet_prediction.enums.meal_type import MealType
from backend.diet_prediction.meal_icons_repository import MealIconsRepository
from backend.diet_prediction.meal_recipes_repository import MealRecipesRepository
from backend.models import MealIcon, MealRecipe
from backend.users.enums.language import Language


class DietPredictionsService:
    def __init__(
        self,
        meal_icons_repository: MealIconsRepository,
        meal_recipes_repository: MealRecipesRepository,
    ):
        self.meal_icons_repository = meal_icons_repository
        self.meal_recipes_repository = meal_recipes_repository

    async def get_meal_icon(self, meal_type: MealType) -> MealIcon:
        meal_icon = await self.meal_icons_repository.get_meal_icon_by_type(meal_type)
        if not meal_icon:
            raise NotFoundInDatabaseException("Meal icon not found")

        return meal_icon

    async def add_meal_recipe(self, meal_recipe: MealRecipe) -> MealRecipe:
        return await self.meal_recipes_repository.add_meal_recipe(meal_recipe)

    async def get_meal_recipe_by_uuid(self, uuid: int) -> MealRecipe:
        meal_recipe = await self.meal_recipes_repository.get_meal_recipe_by_uuid(uuid)
        if not meal_recipe:
            raise NotFoundInDatabaseException("Meal recipe not found")

        return meal_recipe

    async def get_meal_recipes_by_meal_recipe_id(self, meal_id: int) -> List[MealRecipe]:
        meal_recipes = await self.meal_recipes_repository.get_meal_recipes_by_recipe_id(meal_id)
        if not meal_recipes:
            raise NotFoundInDatabaseException("Meal recipes not found")

        return meal_recipes

    async def get_meal_recipe_by_meal_recipe_id_and_language(self, meal_id: int, language: Language) -> MealRecipe:
        meal_recipe = await self.meal_recipes_repository.get_meal_recipe_by_recipe_id_and_language(meal_id, language)
        if not meal_recipe:
            raise NotFoundInDatabaseException("Meal recipe not found")

        return meal_recipe

