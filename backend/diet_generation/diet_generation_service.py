from typing import List
from uuid import UUID

from backend.core.not_found_in_database_exception import NotFoundInDatabaseException
from backend.diet_generation.enums.meal_type import MealType
from backend.diet_generation.meal_icons_repository import MealIconsRepository
from backend.diet_generation.meal_recipes_repository import MealRecipesRepository
from backend.diet_generation.meal_repository import MealRepository
from backend.diet_generation.schemas import MealRecipeResponse
from backend.models import MealIcon, MealRecipe
from backend.users.enums.language import Language


class DietGenerationService:
    def __init__(
        self,
        meal_recipes_repository: MealRecipesRepository,
        meal_repository: MealRepository,
        meal_icons_repository: MealIconsRepository,
    ):
        self.meal_recipes_repository = meal_recipes_repository
        self.meal_repository = meal_repository
        self.meal_icons_repository = meal_icons_repository

    async def get_meal_icon(self, meal_type: MealType) -> MealIcon:
        meal_icon = await self.meal_icons_repository.get_meal_icon_by_type(meal_type)
        return await self.validate_response(meal_icon, "Meal icon not found")

    async def add_meal_recipe(self, meal_recipe: MealRecipe) -> MealRecipe:
        return await self.meal_recipes_repository.add_meal_recipe(meal_recipe)

    async def get_meal_recipe_by_recipe_id(self, recipe_id: UUID) -> MealRecipeResponse:
        meal_recipe = await self.meal_recipes_repository.get_meal_recipe_by_recipe_id(recipe_id)
        meal_recipe = await self.validate_response(meal_recipe)

        meal = await self.meal_repository.get_meal_by_id(meal_recipe.meal_id)
        if not meal:
            raise ValueError(f"Meal with id {meal_recipe.meal_id} not found")

        icon = await self.meal_icons_repository.get_meal_icon_by_id(meal.icon_id)
        if not icon:
            raise ValueError(f"MealIcon with id {meal.icon_id} not found")

        return MealRecipeResponse(
            id=meal_recipe.id,
            meal_id=meal_recipe.meal_id,
            language=meal_recipe.language,
            meal_name=meal_recipe.meal_name,
            meal_description=meal_recipe.meal_description,
            ingredients=meal_recipe.ingredients,
            steps=meal_recipe.steps,
            meal_type=meal.meal_type,
            icon_path=icon.icon_path,
        )

    async def get_meal_recipes_by_meal_recipe_id(self, meal_id: UUID) -> List[MealRecipe]:
        meal_recipes = await self.meal_recipes_repository.get_meal_recipes_by_meal_id(meal_id)
        return await self.validate_response(meal_recipes, "Meal recipes not found")

    async def get_meal_recipe_by_meal_recipe_id_and_language(self, meal_id: UUID, language: Language) -> MealRecipe:
        meal_recipe = await self.meal_recipes_repository.get_meal_recipe_by_meal_id_and_language(meal_id, language)
        return await self.validate_response(meal_recipe)

    @classmethod
    async def validate_response(cls, response, message: str = "Meal recipe not found"):
        if not response:
            raise NotFoundInDatabaseException(message)
        return response
