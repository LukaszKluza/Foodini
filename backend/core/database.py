import redis.asyncio as aioredis
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession
from sqlalchemy.orm import sessionmaker
from backend.Settings import config

engine = create_async_engine(config.DATABASE_URL, echo=True)

SessionLocal = sessionmaker(
    bind=engine, class_=AsyncSession, autoflush=False, autocommit=False
)

redis_tokens = aioredis.Redis(host=config.REDIS_HOST, port=config.REDIS_PORT, db=0)


async def get_db():
    async with SessionLocal() as db:
        yield db


async def get_redis() -> aioredis:
    return redis_tokens
