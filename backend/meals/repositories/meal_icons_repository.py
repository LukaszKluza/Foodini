from uuid import UUID

from sqlalchemy import select
from sqlmodel.ext.asyncio.session import AsyncSession

from backend.meals.enums.meal_type import MealType
from backend.models.meal_icon_model import MealIcon


class MealIconsRepository:
    def __init__(self, db: AsyncSession):
        self.db = db

    async def get_meal_icon_by_id(self, meal_icon_id: UUID) -> MealIcon | None:
        return await self.db.get(MealIcon, meal_icon_id)

    async def get_meal_icon_by_type(self, meal_type: MealType) -> MealIcon | None:
        query = select(MealIcon).where(MealIcon.meal_type == meal_type)
        result = await self.db.execute(query)

        return result.scalar_one_or_none()

    async def get_meal_icon_id_by_type(self, meal_type: MealType) -> UUID | None:
        query = select(MealIcon.id).where(MealIcon.meal_type == meal_type)
        result = await self.db.execute(query)

        return result.scalar_one_or_none()

    async def get_meal_icon_path_by_id(self, meal_id: UUID) -> str | None:
        query = select(MealIcon.id).where(MealIcon.id == meal_id)
        result = await self.db.execute(query)

        return result.scalar_one_or_none()
