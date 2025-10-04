import asyncio

from sqlalchemy import delete
from sqlmodel import SQLModel

from backend.core.database import engine, get_db
from backend.diet_prediction.enums.meal_type import MealType
from backend.models import Meal, MealIcon, User, UserDailyMealItem, UserDailySummary, UserDetails

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


# Data for tests. To delete when we add real data
MEALS = [
    {
        "id": 1,
        "name": "Breakfast",
        "description": "Typical breakfast meal",
        "recipe": "Fried eggs with toast",
        "meal_type": "BREAKFAST",
        "meal_icon_id": 1,
        "calories": 350,
        "protein": 20.0,
        "fat": 15.0,
        "carbs": 35.0,
    },
    {
        "id": 2,
        "name": "Morning Snack",
        "description": "Light snack for mid-morning",
        "recipe": "Yogurt and fruits",
        "meal_type": "MORNING_SNACK",
        "meal_icon_id": 2,
        "calories": 150,
        "protein": 5.0,
        "fat": 3.0,
        "carbs": 25.0,
    },
    {
        "id": 3,
        "name": "Lunch",
        "description": "Main midday meal",
        "recipe": "Chicken salad with rice",
        "meal_type": "LUNCH",
        "meal_icon_id": 3,
        "calories": 600,
        "protein": 35.0,
        "fat": 20.0,
        "carbs": 60.0,
    },
    {
        "id": 4,
        "name": "Afternoon Snack",
        "description": "Snack to keep energy up",
        "recipe": "Nuts and fruits",
        "meal_type": "AFTERNOON_SNACK",
        "meal_icon_id": 4,
        "calories": 200,
        "protein": 5.0,
        "fat": 10.0,
        "carbs": 25.0,
    },
    {
        "id": 5,
        "name": "Dinner",
        "description": "Evening meal",
        "recipe": "Grilled salmon with vegetables",
        "meal_type": "DINNER",
        "meal_icon_id": 5,
        "calories": 550,
        "protein": 40.0,
        "fat": 25.0,
        "carbs": 35.0,
    },
    {
        "id": 6,
        "name": "Evening Snack",
        "description": "Light meal before bed",
        "recipe": "Cheese and fruits",
        "meal_type": "EVENING_SNACK",
        "meal_icon_id": 6,
        "calories": 180,
        "protein": 8.0,
        "fat": 8.0,
        "carbs": 20.0,
    },
]


async def create_tables():
    async with engine.begin() as conn:
        await conn.run_sync(SQLModel.metadata.create_all)


async def init_meal_icons():
    async for db in get_db():
        await db.execute(delete(Meal))
        await db.execute(delete(MealIcon))

        for meal_icon in MEAL_ICONS:
            db.add(MealIcon(**meal_icon))

        await db.commit()


async def init_meals():
    async for db in get_db():
        for meal in MEALS:
            db.add(Meal(**meal))

        await db.commit()


async def main():
    await create_tables()
    await init_meal_icons()
    await init_meals()


if __name__ == "__main__":
    asyncio.run(main())
