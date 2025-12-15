from datetime import date
from uuid import UUID

from sqlalchemy import delete, select, update
from sqlalchemy.orm import contains_eager, selectinload
from sqlmodel.ext.asyncio.session import AsyncSession

from backend.core.not_found_in_database_exception import NotFoundInDatabaseException
from backend.daily_summary.enums.meal_status import MealStatus
from backend.daily_summary.schemas import DailyMacrosSummaryCreate, DailyMealsCreate, MealInfo
from backend.meals.enums.meal_type import MealType
from backend.models.composed_meal_item import ComposedMealItem
from backend.models.meal_model import Meal
from backend.models.meals_daily_summary import MealDailySummary
from backend.models.user_daily_summary_model import DailyMacrosSummary, DailyMealsSummary


class DailySummaryRepository:
    def __init__(self, db: AsyncSession):
        self.db = db

    async def add_daily_meals_summary(self, daily_meals_data: DailyMealsCreate, user_id: UUID) -> DailyMealsSummary:
        user_daily_meals = DailyMealsSummary(user_id=user_id, **daily_meals_data.model_dump(exclude={"meals"}))

        self.db.add(user_daily_meals)
        await self.db.flush()

        for meal_type, meal_infos in daily_meals_data.meals.items():
            if not meal_infos:
                continue

            meal_daily_summary_link = MealDailySummary(
                daily_summary_id=user_daily_meals.id,
                status=meal_infos[0].status,
                meal_type=meal_type,
            )
            self.db.add(meal_daily_summary_link)
            await self.db.flush()

            for meal in meal_infos:
                composed_meal = ComposedMealItem(
                    meal_daily_summary_id=meal_daily_summary_link.id,
                    meal_id=meal.meal_id,
                    planned_calories=meal.calories,
                    planned_protein=meal.protein,
                    planned_fat=meal.fat,
                    planned_carbs=meal.carbs,
                    planned_weight=meal.unit_weight,
                )
                self.db.add(composed_meal)

        await self.db.commit()
        await self.db.refresh(user_daily_meals)
        return user_daily_meals

    async def get_daily_summary(self, user_id: UUID, day: date) -> DailyMealsSummary | None:
        query = (
            select(DailyMealsSummary)
            .where(DailyMealsSummary.user_id == user_id, DailyMealsSummary.day == day)
            .options(
                selectinload(DailyMealsSummary.daily_meals)
                .selectinload(MealDailySummary.meal_items)
                .selectinload(ComposedMealItem.meal)
            )
        )

        result = await self.db.execute(query)
        return result.unique().scalar_one_or_none()

    async def get_daily_meal_type_summary(self, user_id: UUID, day: date, meal_type: MealType) -> DailyMealsSummary:
        query = (
            select(DailyMealsSummary)
            .join(DailyMealsSummary.daily_meals)
            .where(
                DailyMealsSummary.user_id == user_id,
                DailyMealsSummary.day == day,
                MealDailySummary.meal_type == meal_type,
            )
            .options(contains_eager(DailyMealsSummary.daily_meals))
        )

        result = await self.db.execute(query)
        return result.unique().scalar_one_or_none()

    async def get_daily_meals_summary(self, user_id: UUID, day: date) -> DailyMealsSummary | None:
        query = (
            select(DailyMealsSummary)
            .where(DailyMealsSummary.user_id == user_id, DailyMealsSummary.day == day)
            .options(
                selectinload(DailyMealsSummary.daily_meals)
                .selectinload(MealDailySummary.meal_items)
                .selectinload(ComposedMealItem.meal)
                .selectinload(Meal.recipes)
            )
        )
        result = await self.db.execute(query)
        return result.scalar_one_or_none()

    async def remove_daily_meals_summary(self, daily_summary_id: UUID) -> None:
        stmt = select(DailyMealsSummary).where(DailyMealsSummary.id == daily_summary_id)
        result = await self.db.execute(stmt)
        daily_summary = result.scalars().first()

        if daily_summary is None:
            raise NotFoundInDatabaseException(f"DailyMealsSummary with ID {daily_summary_id} not found.")

        meal_summary_stmt = select(MealDailySummary.id).where(MealDailySummary.daily_summary_id == daily_summary_id)
        meal_summary_ids_result = await self.db.execute(meal_summary_stmt)
        meal_summary_ids = meal_summary_ids_result.scalars().all()

        if meal_summary_ids:
            delete_composed_stmt = delete(ComposedMealItem).where(
                ComposedMealItem.meal_daily_summary_id.in_(meal_summary_ids)
            )
            await self.db.execute(delete_composed_stmt)

            delete_meal_summary_stmt = delete(MealDailySummary).where(
                MealDailySummary.daily_summary_id == daily_summary_id
            )
            await self.db.execute(delete_meal_summary_stmt)

        await self.db.delete(daily_summary)

        await self.db.commit()

    async def add_daily_macros_summary(
        self, daily_summary_data: DailyMacrosSummaryCreate, user_id: UUID
    ) -> DailyMacrosSummary:
        user_daily_macros_summary = DailyMacrosSummary(user_id=user_id, **daily_summary_data.model_dump())

        self.db.add(user_daily_macros_summary)
        await self.db.commit()
        await self.db.refresh(user_daily_macros_summary)
        return user_daily_macros_summary

    async def get_daily_macros_summary(self, user_id: UUID, day: date) -> DailyMacrosSummary | None:
        query = select(DailyMacrosSummary).where(DailyMacrosSummary.user_id == user_id, DailyMacrosSummary.day == day)
        result = await self.db.execute(query)
        return result.scalar_one_or_none()

    async def update_daily_macros_summary(
        self, user_id: UUID, daily_summary_data: DailyMacrosSummaryCreate, day: date
    ) -> DailyMacrosSummary | None:
        user_daily_macros = await self.get_daily_macros_summary(user_id, day)
        if user_daily_macros:
            await self.db.execute(
                update(DailyMacrosSummary)
                .where(DailyMacrosSummary.user_id == user_id, DailyMacrosSummary.day == day)
                .values(**daily_summary_data.model_dump())
            )
            await self.db.commit()
            await self.db.refresh(user_daily_macros)
            return user_daily_macros
        return None

    async def update_meal_status(
        self, user_id: UUID, day: date, meal_type: MealType, new_status: MealStatus
    ) -> DailyMealsSummary | None:
        user_daily_meals_summary = await self.get_daily_meals_summary(user_id, day)
        if user_daily_meals_summary:
            summary_id = user_daily_meals_summary.id
            await self.db.execute(
                update(MealDailySummary)
                .where(
                    MealDailySummary.daily_summary_id == summary_id,
                    MealDailySummary.meal_type == meal_type,
                )
                .values(status=new_status)
            )
            await self.db.commit()
            await self.db.refresh(user_daily_meals_summary)
            return user_daily_meals_summary
        return None

    async def add_custom_meal(
        self, user_id: UUID, day: date, meal_type: MealType, meal_info: MealInfo
    ) -> DailyMealsSummary | None:
        user_daily_meals_summary = await self.get_daily_meals_summary(user_id, day)

        if user_daily_meals_summary:
            meal_daily_summary = next(
                (link for link in user_daily_meals_summary.daily_meals if link.meal_type == meal_type),
                None,
            )
            if not meal_daily_summary:
                meal_daily_summary = MealDailySummary(
                    daily_summary_id=user_daily_meals_summary.id,
                    meal_type=meal_info.meal_type,
                    status=meal_info.status,
                    is_active=True,
                )
                self.db.add(meal_daily_summary)
                await self.db.flush()

            composed_item = ComposedMealItem(
                meal_daily_summary_id=meal_daily_summary.id,
                meal_id=meal_info.meal_id,
                planned_weight=meal_info.planned_weight,
                planned_calories=meal_info.planned_calories,
                planned_protein=meal_info.planned_protein,
                planned_carbs=meal_info.planned_carbs,
                planned_fat=meal_info.planned_fat,
            )
            self.db.add(composed_item)
            await self.db.commit()
            await self.db.refresh(user_daily_meals_summary)
            return user_daily_meals_summary
        return None

    async def remove_meal_from_summary(self, user_id: UUID, day: date, meal_type: MealType, meal_id: UUID) -> bool:
        user_daily_meals_summary = await self.get_daily_meals_summary(user_id, day)
        if user_daily_meals_summary:
            meal_daily_summary = next(
                (meal for meal in user_daily_meals_summary.daily_meals if meal.meal_type == meal_type), None
            )

            if meal_daily_summary:
                composed_item = next(
                    (item for item in meal_daily_summary.meal_items if item.meal_id == meal_id),
                    None,
                )
                if composed_item:
                    await self.db.delete(composed_item)
                    await self.db.commit()
                    return True
        return False
