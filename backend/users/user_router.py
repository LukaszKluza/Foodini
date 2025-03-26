from fastapi import APIRouter, Depends, status
from .schemas import UserCreate, UserResponse, UserUpdate, UserLogin
from .user_service import UserService, get_user_service

user_router = APIRouter(prefix="/v1/users")


@user_router.post("/register", response_model=UserResponse)
async def register_user(
    user: UserCreate, user_service: UserService = Depends(get_user_service)
):
    return await user_service.register(user)


@user_router.post("/login", response_model=UserResponse)
async def login_user(
    user: UserLogin, user_service: UserService = Depends(get_user_service)
):
    return await user_service.login(user)


@user_router.get("/logout", status_code=status.HTTP_204_NO_CONTENT)
async def logout_user(
    user_id: int, user_service: UserService = Depends(get_user_service)
):
    return await user_service.logout(user_id)


@user_router.patch("/update", response_model=UserResponse)
async def update_user(
    user: UserUpdate, user_service: UserService = Depends(get_user_service)
):
    return await user_service.update(user)


@user_router.delete("/delete/{user_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_user(
    user_id: int, user_service: UserService = Depends(get_user_service)
):
    return await user_service.delete(user_id)
