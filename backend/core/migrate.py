from sqlalchemy import select
from sqlmodel import SQLModel
from backend.core.database import engine, SessionLocal
from backend.models import (
    UserDetails,
    AllergyLink,
    User,
    ActivityLevel,
    Allergies,
    DietIntensivity,
    DietType,
    Gender,
    SleepQuality,
    StressLevel,
)
from backend.user_details.enums import (
    ActivityLevel as ActivityLevelEnum,
    Allergies as AllergiesEnum,
    DietIntensivity as DietIntensivityEnum,
    DietType as DietTypeEnum,
    Gender as GenderEnum,
    SleepQuality as SleepQualityEnum,
    StressLevel as StressLevelEnum,
)
import asyncio


async def create_tables():
    async with engine.begin() as conn:
        await conn.run_sync(SQLModel.metadata.create_all)


async def populate_enum_tables():
    async with SessionLocal() as session:

        async def insert_unique_values(model, enum_class):
            for value in enum_class:
                result = await session.execute(
                    select(model).where(model.name == value.value)
                )
                if not result.scalars().first():
                    session.add(model(name=value.value))
            await session.commit()

        await insert_unique_values(Gender, GenderEnum)
        await insert_unique_values(DietType, DietTypeEnum)
        await insert_unique_values(DietIntensivity, DietIntensivityEnum)
        await insert_unique_values(ActivityLevel, ActivityLevelEnum)
        await insert_unique_values(StressLevel, StressLevelEnum)
        await insert_unique_values(SleepQuality, SleepQualityEnum)
        await insert_unique_values(Allergies, AllergiesEnum)


async def main():
    await create_tables()
    await populate_enum_tables()


if __name__ == "__main__":
    asyncio.run(main())
