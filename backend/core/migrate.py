from sqlmodel import SQLModel
from .database import engine
from users.models import User
import asyncio


async def create_tables():
    async with engine.begin() as conn:
        await conn.run_sync(SQLModel.metadata.create_all)


if __name__ == "__main__":
    asyncio.run(create_tables())
