from typing import List
from uuid import UUID

from backend.core.not_found_in_database_exception import NotFoundInDatabaseException
from backend.meals.enums.meal_type import MealType
from backend.meals.repositories.meal_icons_repository import MealIconsRepository
from backend.meals.repositories.meal_recipes_repository import MealRecipesRepository
from backend.meals.repositories.meal_repository import MealRepository
from backend.meals.schemas import MealRecipeResponse
from backend.models import Meal, MealIcon, MealRecipe
from backend.users.enums.language import Language


class MealService:
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

    async def get_meal_icon_id(self, meal_type: MealType) -> UUID:
        return await self.meal_icons_repository.get_meal_icon_id_by_type(meal_type)

    async def get_meal_icon_path_by_id(self, icon_id: UUID) -> str:
        return await self.meal_icons_repository.get_meal_icon_path_by_id(icon_id)

    async def add_meal(self, meal: Meal) -> Meal:
        return await self.meal_recipes_repository.add_meal(meal)

    async def add_meal_recipe(self, meal_recipe: MealRecipe) -> MealRecipe:
        return await self.meal_recipes_repository.add_meal_recipe(meal_recipe)

    async def get_meal_recipes_by_meal_recipe_id(self, meal_id: UUID) -> List[MealRecipeResponse]:
        meal_recipes = await self.meal_recipes_repository.get_meal_recipes_by_meal_id(meal_id)
        meal_recipes = await self.validate_response(meal_recipes, "Meal recipes not found")
        meal_recipes_response = []

        for meal_recipe in meal_recipes:
            meal_recipes_response.append(await self._enhance_meal_response_by_icon(meal_recipe))

        return meal_recipes_response

    async def get_meal_recipe_by_meal_recipe_id_and_language(
        self, meal_id: UUID, language: Language
    ) -> MealRecipeResponse:
        meal_recipe = await self.meal_recipes_repository.get_meal_recipe_by_meal_id_and_language(meal_id, language)
        meal_recipe = await self.validate_response(meal_recipe)

        return await self._enhance_meal_response_by_icon(meal_recipe)

    async def _enhance_meal_response_by_icon(self, meal_recipe: MealRecipe) -> MealRecipeResponse:
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

    @classmethod
    async def validate_response(cls, response, message: str = "Meal recipe not found"):
        if not response:
            raise NotFoundInDatabaseException(message)
        return response
