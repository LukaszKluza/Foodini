from fastapi import HTTPException, status
from fastapi.params import Depends

from backend.users.service.authorisation_service import AuthorizationService
from backend.users.service.password_service import PasswordService
from backend.users.schemas import (
    UserCreate,
    UserLogin,
    UserUpdate,
    LoginUserResponse,
)
from backend.users.user_repository import UserRepository, get_user_repository


async def check_user_permission(user_id_from_token: int, user_id: int):
    if user_id_from_token != user_id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN, detail="Invalid token"
        )


class UserService:
    def __init__(self, user_repository: UserRepository = Depends(get_user_repository)):
        self.user_repository = user_repository

    async def register(self, user: UserCreate):
        existing_user = await self.user_repository.get_user_by_email(user.email)
        if existing_user:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="User already exists",
            )
        user.password = await PasswordService.hash_password(user.password)
        new_user = await self.user_repository.create_user(user)
        return new_user

    async def login(self, user: UserLogin):
        user_ = await self.user_repository.get_user_by_email(user.email)
        if not user_:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Incorrect credentials",
            )

        if not await PasswordService.verify_password(user.password, user_.password):
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Incorrect password",
            )
        access_token, refresh_token = await AuthorizationService.create_tokens(
            {"sub": user_.email, "id": user_.id}
        )

        return LoginUserResponse(
            id=user_.id,
            email=user_.email,
            access_token=access_token,
            refresh_token=refresh_token,
        )

    async def logout(self, user_id: int):
        user_ = await self.user_repository.get_user_by_id(user_id)
        if not user_:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="User with this ID does not exist",
            )

        return HTTPException(status_code=status.HTTP_200_OK, detail="Logged out")

    async def update(self, user_id_from_token: int, user: UserUpdate):
        await check_user_permission(user_id_from_token, user.user_id)
        user_ = await self.user_repository.get_user_by_id(user.user_id)
        if not user_:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="User with this ID does not exist",
            )

        return await self.user_repository.update_user(user.user_id, user)

    async def delete(self, user_id_from_token: int, user_id: int):
        await check_user_permission(user_id_from_token, user_id)
        user_ = await self.user_repository.get_user_by_id(user_id)
        if not user_:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="User with this ID does not exist",
            )

        return await self.user_repository.delete_user(user_id)


def get_user_service(
    user_repository: UserRepository = Depends(get_user_repository),
) -> UserService:
    return UserService(user_repository)
