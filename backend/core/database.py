import redis.asyncio as aioredis
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession
from sqlalchemy.orm import sessionmaker
from backend.Settings import DATABASE_URL

engine = create_async_engine(DATABASE_URL, echo=True)

SessionLocal = sessionmaker(
    bind=engine, class_=AsyncSession, autoflush=False, autocommit=False
)

redis_tokens = aioredis.Redis(host="127.0.0.1", port=6379, db=0)


async def get_db():
    async with SessionLocal() as db:
        yield db
