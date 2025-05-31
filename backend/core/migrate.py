from sqlalchemy import select
from sqlmodel import SQLModel
from backend.core.database import engine, SessionLocal
from backend.models import (
    UserDetails,
    User,
)
import asyncio


async def create_tables():
    async with engine.begin() as conn:
        await conn.run_sync(SQLModel.metadata.create_all)


async def main():
    await create_tables()


if __name__ == "__main__":
    asyncio.run(main())
