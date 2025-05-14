from sqlmodel import SQLModel
from backend.core.database import engine
from backend.models import User, UserDetails
import asyncio


async def create_tables():
    async with engine.begin() as conn:
        await conn.run_sync(SQLModel.metadata.create_all)


if __name__ == "__main__":
    asyncio.run(create_tables())
