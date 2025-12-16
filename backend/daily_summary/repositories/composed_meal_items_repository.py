from uuid import UUID

from sqlalchemy import select
from sqlalchemy.orm import selectinload
from sqlmodel.ext.asyncio.session import AsyncSession

from backend.daily_summary.schemas import ComposedMealItemUpdateEntity
from backend.models.composed_meal_item import ComposedMealItem
from backend.models.meals_daily_summary import MealDailySummary
from backend.models.user_daily_summary_model import DailyMealsSummary


class ComposedMealItemsRepository:
    def __init__(self, db: AsyncSession):
        self.db = db

    async def get_composed_meal_item_by_id(self, composed_meal_item_id: UUID) -> ComposedMealItem | None:
        return await self.db.get(ComposedMealItem, composed_meal_item_id)

    async def get_composed_meal_item_by_meal_id(self, meal_id: UUID) -> ComposedMealItem | None:
        query = select(ComposedMealItem).where(ComposedMealItem.meal_id == meal_id)
        result = await self.db.execute(query)
        return result.scalar_one_or_none()

    async def get_composed_meal_item_with_summary(self, user_id: UUID, meal_id: UUID) -> ComposedMealItem | None:
        query = (
            select(ComposedMealItem)
            .options(selectinload(ComposedMealItem.daily_meal).selectinload(MealDailySummary.daily_summary))
            .where(
                ComposedMealItem.meal_id == meal_id,
                ComposedMealItem.daily_meal.has(
                    MealDailySummary.daily_summary.has(DailyMealsSummary.user_id == user_id)
                ),
            )
        )

        result = await self.db.execute(query)
        return result.scalar_one_or_none()

    async def get_composed_meal_item_with_summary_and_origin_meal(
        self, user_id: UUID, meal_id: UUID
    ) -> ComposedMealItem | None:
        query = (
            select(ComposedMealItem)
            .options(
                selectinload(ComposedMealItem.daily_meal).selectinload(MealDailySummary.daily_summary),
                selectinload(ComposedMealItem.meal),
            )
            .where(
                ComposedMealItem.meal_id == meal_id,
                ComposedMealItem.daily_meal.has(
                    MealDailySummary.daily_summary.has(DailyMealsSummary.user_id == user_id)
                ),
            )
        )

        result = await self.db.execute(query)
        return result.scalar_one_or_none()

    async def add_composed_meal_item(self, composed_meal_item: ComposedMealItem) -> ComposedMealItem:
        self.db.add(composed_meal_item)
        await self.db.commit()
        await self.db.refresh(composed_meal_item)
        return composed_meal_item

    async def update_composed_meal_item(
        self, composed_meal_item_id: UUID, update_request: ComposedMealItemUpdateEntity
    ) -> ComposedMealItem | None:
        composed_meal_item = await self.get_composed_meal_item_by_id(composed_meal_item_id)
        if composed_meal_item:
            update_fields = update_request.model_dump(exclude_unset=True)
            for key, value in update_fields.items():
                setattr(composed_meal_item, key, value)
            await self.db.commit()
            await self.db.refresh(composed_meal_item)
            return composed_meal_item
        return None
