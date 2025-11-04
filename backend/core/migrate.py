import asyncio

from sqlalchemy import delete, func, select
from sqlmodel import SQLModel

from backend.core.database import engine, get_db
from backend.meals.test.test_data import MEAL_ICONS, MEAL_RECIPES
from backend.models import MealIcon, MealRecipe


async def create_tables():
    async with engine.begin() as conn:
        await conn.run_sync(SQLModel.metadata.create_all)


async def init_meal_icons():
    async for db in get_db():
        count = await db.scalar(select(func.count()).select_from(MealIcon))
        if count == 0:
            for meal_icon in MEAL_ICONS:
                db.add(MealIcon(**meal_icon))
            await db.commit()


async def init_meal_recipes():
    async for db in get_db():
        await db.execute(delete(MealRecipe))

        for meal_recipe in MEAL_RECIPES:
            db.add(meal_recipe)

        await db.commit()


async def main():
    await create_tables()
    await init_meal_icons()


if __name__ == "__main__":
    asyncio.run(main())
