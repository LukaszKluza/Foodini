import redis.asyncio as aioredis
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession
from sqlalchemy.orm import sessionmaker
from backend.Settings import DATABASE_URL, REDIS_HOST, REDIS_PORT

engine = create_async_engine(DATABASE_URL, echo=True)

SessionLocal = sessionmaker(
    bind=engine, class_=AsyncSession, autoflush=False, autocommit=False
)

redis_tokens = aioredis.Redis(host=REDIS_HOST, port=REDIS_PORT, db=0)


async def get_db():
    async with SessionLocal() as db:
        yield db
