from typing import Any, Sequence

from sqlalchemy import Row, RowMapping, select
from sqlmodel.ext.asyncio.session import AsyncSession

from backend.models import MealRecipe
from backend.models.meal_recipe_model import Ingredients, Step, Ingredient
from backend.users.enums.language import Language


class MealRecipesRepository:
    def __init__(self, db: AsyncSession):
        self.db = db

    async def get_meal_recipe_by_uuid(self, uuid: int) -> MealRecipe | None:
        result = await self.db.get(MealRecipe, uuid)
        return result

    async def get_meal_recipes_by_recipe_id(self, meal_id: int) -> Sequence[Row[Any] | RowMapping | Any]:
        query = select(MealRecipe).where(MealRecipe.meal_id == meal_id)
        result = await self.db.execute(query)

        rows = result.scalars().all()
        for row in rows:
            await self._map_meal_recipe(row)
        return rows

    async def get_meal_recipe_by_recipe_id_and_language(self, meal_id: int, language: Language) -> MealRecipe | None:
        query = select(MealRecipe).where((MealRecipe.meal_id == meal_id) & (MealRecipe.language == language))
        result = await self.db.execute(query)

        return await self._map_meal_recipe(result.scalars().one_or_none())

    async def add_meal_recipe(self, meal_recipe: MealRecipe) -> MealRecipe:
        self.db.add(meal_recipe)
        await self.db.commit()
        await self.db.refresh(meal_recipe)
        return meal_recipe

    @classmethod
    async def _map_meal_recipe(cls, meal_recipe) -> MealRecipe:
        if meal_recipe:
            meal_recipe.ingredients = Ingredients(**meal_recipe.ingredients)
            meal_recipe.steps = [Step(**s) for s in meal_recipe.steps]
        return meal_recipe
