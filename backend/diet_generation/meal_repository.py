from sqlalchemy import select, update
from sqlalchemy.ext.asyncio import AsyncSession

from backend.diet_generation.schemas import MealCreate
from backend.models import Meal


class MealRepository:
    def __init__(self, db: AsyncSession):
        self.db = db

    async def add_meal(self, meal_data: MealCreate) -> Meal:
        meal = Meal(**meal_data.model_dump())
        self.db.add(meal)
        await self.db.commit()
        await self.db.refresh(meal)
        return meal

    async def update_meal(self, meal_data: MealCreate) -> MealCreate | None:
        meal_name = meal_data.meal_name
        meal = await self.get_meal_by_name(meal_name)
        if meal:
            await self.db.execute(update(Meal).where(Meal.meal_name == meal_name).values(**meal_data.model_dump()))
            await self.db.commit()
            await self.db.refresh(meal)
            return meal
        return None

    async def get_meal_by_id(self, meal_id: int) -> Meal | None:
        query = select(Meal).where(Meal.id == meal_id)
        result = await self.db.execute(query)
        return result.scalar_one_or_none()

    async def get_meal_by_name(self, meal_name: str) -> Meal | None:
        query = select(Meal).where(Meal.name == meal_name)
        result = await self.db.execute(query)
        return result.scalar_one_or_none()

    async def get_meal_calories_by_id(self, meal_id: int) -> int | None:
        query = select(Meal.calories).where(Meal.id == meal_id)
        result = await self.db.execute(query)
        return result.scalar_one_or_none()

    async def get_meal_protein_by_id(self, meal_id: int) -> int | None:
        query = select(Meal.protein).where(Meal.id == meal_id)
        result = await self.db.execute(query)
        return result.scalar_one_or_none()

    async def get_meal_carbs_by_id(self, meal_id: int) -> int | None:
        query = select(Meal.carbs).where(Meal.id == meal_id)
        result = await self.db.execute(query)
        return result.scalar_one_or_none()

    async def get_meal_fats_by_id(self, meal_id: int) -> int | None:
        query = select(Meal.fats).where(Meal.id == meal_id)
        result = await self.db.execute(query)
        return result.scalar_one_or_none()
