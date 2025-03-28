from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession
from sqlalchemy.orm import sessionmaker
from backend.Settings import DATABASE_URL

engine = create_async_engine(DATABASE_URL, echo=True)

SessionLocal = sessionmaker(
    bind=engine, class_=AsyncSession, autoflush=False, autocommit=False
)


async def get_db():
    async with SessionLocal() as db:
        yield db
