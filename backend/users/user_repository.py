from fastapi.params import Depends
from pydantic import EmailStr
from sqlmodel.ext.asyncio.session import AsyncSession
from .models import User
from .schemas import UserCreate, UserUpdate
from sqlalchemy.future import select

from backend.core.database import get_db


class UserRepository:
    def __init__(self, db: AsyncSession):
        self.db = db

    async def create_user(self, user_data: UserCreate) -> User:
        user = User(**user_data.model_dump())
        self.db.add(user)
        await self.db.commit()
        await self.db.refresh(user)
        return user

    async def get_user_by_id(self, user_id: int) -> User:
        return await self.db.get(User, user_id)

    async def get_user_by_email(self, email: EmailStr) -> User:
        query = select(User).where(User.email == email)
        result = await self.db.execute(query)
        return result.scalar_one_or_none()

    async def update_user(self, user_id: int, user_data: UserUpdate) -> User:
        user = User(id=user_id, **user_data.model_dump(exclude_unset=True))
        updated_user = await self.db.merge(user)
        await self.db.commit()
        await self.db.refresh(updated_user)
        return updated_user

    async def delete_user(self, user_id: int) -> bool:
        user = await self.get_user_by_id(user_id)
        if user:
            await self.db.delete(user)
            await self.db.commit()
            await self.db.flush()
            return True
        return False


async def get_user_repository(db: AsyncSession = Depends(get_db)) -> UserRepository:
    return UserRepository(db)
