import datetime
from typing import Type

from pydantic import EmailStr
from sqlmodel.ext.asyncio.session import AsyncSession

from backend.models import User
from backend.core.not_found_in_database_exception import NotFoundInDatabaseException
from backend.users.schemas import UserCreate, UserUpdate
from sqlalchemy.future import select

from backend.models.user_model import Language


class UserRepository:
    def __init__(self, db: AsyncSession):
        self.db = db

    async def create_user(self, user_data: UserCreate) -> User:
        user = User(**user_data.model_dump())
        self.db.add(user)
        await self.db.commit()
        await self.db.refresh(user)
        return user

    async def get_user_by_id(self, user_id: int) -> Type[User]:
        user = await self.db.get(User, user_id)

        if user is None:
            raise NotFoundInDatabaseException("User not found")

        return user

    async def get_user_by_email(self, email: EmailStr) -> Type[User]:
        query = select(User).where(User.email == email)
        result = await self.db.execute(query)
        user = result.scalar_one_or_none()

        if user is None:
            raise NotFoundInDatabaseException("User not found")

        return user

    async def update_user(
        self, user_id: int, user_data: UserUpdate
    ) -> Type[User] | None:
        user = await self.get_user_by_id(user_id)
        if user:
            update_fields = user_data.model_dump(exclude_unset=True)
            for key, value in update_fields.items():
                setattr(user, key, value)
            await self.db.commit()
            await self.db.refresh(user)
            return user
        return None

    async def change_language(
        self, user_id: int, language: Language
    ) -> Type[User] | None:
        user = await self.get_user_by_id(user_id)
        if user:
            user.language = language.value
            updated_user = await self.db.merge(user)
            await self.db.commit()
            await self.db.refresh(updated_user)
            return updated_user
        return None

    async def update_password(
        self, user_id: int, new_password: str, current_datetime: datetime
    ) -> Type[User] | None:
        user = await self.get_user_by_id(user_id)
        if user:
            user.password = new_password
            user.last_password_update = current_datetime
            await self.db.commit()
            await self.db.refresh(user)
            return user
        return None

    async def delete_user(self, user_id: int) -> Type[User] | None:
        user = await self.get_user_by_id(user_id)
        if user:
            await self.db.delete(user)
            await self.db.commit()
            await self.db.flush()
            return user
        return None

    async def verify_user(self, user_email: EmailStr) -> User | None:
        user = await self.get_user_by_email(user_email)
        if user:
            user.is_verified = True
            await self.db.commit()
            await self.db.refresh(user)
            return user
        return None
