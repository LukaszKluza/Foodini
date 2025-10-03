import asyncio

from sqlalchemy import delete
from sqlmodel import SQLModel

from backend.core.database import engine, get_db
from backend.diet_prediction.enums.meal_type import MealType
from backend.models import MealIcon, User, UserDetails, UserDailyMealItem, UserDailySummary, Meal

MEAL_ICONS = [
    {"id": 1, "meal_type": MealType.BREAKFAST, "icon_path": "db/pictures_meals/black-coffee-fried-egg-with-toasts.jpg"},
    {"id": 2, "meal_type": MealType.MORNING_SNACK, "icon_path": "db/pictures_meals/high-angle-tasty-breakfast-bed.jpg"},
    {"id": 3, "meal_type": MealType.LUNCH, "icon_path": "db/pictures_meals/noodle-soup-winter-meals-seeds.jpg"},
    {
        "id": 4,
        "meal_type": MealType.AFTERNOON_SNACK,
        "icon_path": "db/pictures_meals/top-view-tasty-salad-with-vegetables.jpg",
    },
    {
        "id": 5,
        "meal_type": MealType.DINNER,
        "icon_path": "db/pictures_meals/seafood-salad-with-salmon-shrimp-mussels-herbs-tomatoes.jpg",
    },
    {
        "id": 6,
        "meal_type": MealType.EVENING_SNACK,
        "icon_path": "db/pictures_meals/charcuterie-board-with-cold-cuts-fresh-fruits-cheese.jpg",
    },
]


async def create_tables():
    async with engine.begin() as conn:
        await conn.run_sync(SQLModel.metadata.create_all)


async def init_meal_icons():
    async for db in get_db():
        await db.execute(delete(MealIcon))

        for meal_icon in MEAL_ICONS:
            db.add(MealIcon(**meal_icon))

        await db.commit()


async def main():
    await create_tables()
    await init_meal_icons()


if __name__ == "__main__":
    asyncio.run(main())
