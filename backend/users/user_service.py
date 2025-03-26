from fastapi import HTTPException
from fastapi.params import Depends

from .schemas import UserCreate, UserLogin, UserUpdate
from .user_repository import UserRepository, get_user_repository


class UserService:
    def __init__(self, user_repository: UserRepository = Depends(get_user_repository)):
        self.user_repository = user_repository

    async def register(self, user: UserCreate):
        existing_user = await self.user_repository.get_user_by_email(user.email)
        if existing_user:
            raise HTTPException(status_code=400, detail="User already exists")

        new_user = await self.user_repository.create_user(user)
        return new_user

    async def login(self, user: UserLogin):
        user_ = await self.user_repository.get_user_by_email(user.email)
        if not user_:
            raise HTTPException(status_code=400, detail="Incorrect credentials")
        if user.password != user_.password:
            raise HTTPException(status_code=401, detail="Incorrect password")
        return user_

    async def logout(self, user_id: int):
        user_ = await self.user_repository.get_user_by_id(user_id)
        if not user_:
            raise HTTPException(
                status_code=404, detail="User with this ID does not exist"
            )

        return HTTPException(status_code=200, detail="Logged out")

    async def update(self, user: UserUpdate):
        user_ = await self.user_repository.get_user_by_id(user.user_id)
        if not user_:
            raise HTTPException(
                status_code=404, detail="User with this ID does not exist"
            )

        return await self.user_repository.update_user(user.user_id, user)

    async def delete(self, user_id: int):
        user_ = await self.user_repository.get_user_by_id(user_id)
        if not user_:
            raise HTTPException(
                status_code=404, detail="User with this ID does not exist"
            )

        return await self.user_repository.delete_user(user_id)


def get_user_service(
    user_repository: UserRepository = Depends(get_user_repository),
) -> UserService:
    return UserService(user_repository)
