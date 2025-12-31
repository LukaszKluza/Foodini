from uuid import UUID

from sqlalchemy import select, update
from sqlalchemy.orm import selectinload
from sqlmodel.ext.asyncio.session import AsyncSession

from backend.daily_summary.schemas import ComposedMealItemUpdateEntity
from backend.models.composed_meal_item_model import ComposedMealItem
from backend.models.daily_summary_model import DailySummary
from backend.models.meal_type_daily_summary import MealTypeDailySummary


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
            .options(selectinload(ComposedMealItem.daily_meal).selectinload(MealTypeDailySummary.daily_summary))
            .where(
                ComposedMealItem.meal_id == meal_id,
                ComposedMealItem.daily_meal.has(
                    MealTypeDailySummary.daily_summary.has(DailySummary.user_id == user_id)
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
                selectinload(ComposedMealItem.daily_meal).selectinload(MealTypeDailySummary.daily_summary),
                selectinload(ComposedMealItem.meal),
            )
            .where(
                ComposedMealItem.meal_id == meal_id,
                ComposedMealItem.daily_meal.has(
                    MealTypeDailySummary.daily_summary.has(DailySummary.user_id == user_id)
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

    async def remove_meal_from_summary(self, composed_meal_item_id: UUID) -> bool:
        result = await self.db.execute(
            update(ComposedMealItem)
            .where(
                ComposedMealItem.id == composed_meal_item_id,
                ComposedMealItem.is_active,
            )
            .values(is_active=False)
            .returning(ComposedMealItem.id)
        )

        updated_id = result.scalar_one_or_none()
        if not updated_id:
            return False

        await self.db.commit()
        return True
