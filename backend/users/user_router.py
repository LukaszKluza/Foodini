from fastapi import APIRouter, status, HTTPException

from backend.users import user_crud
from schemas import UserCreate, UserResponse, UserUpdate, UserLogin

router = APIRouter(prefix="/v1/users")


@router.post("/register", response_model=UserResponse)
async def register_user(user: UserCreate):
    try:
        return await user_crud.register(user)
    except Exception as e:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(e))


@router.post("/login", response_model=UserResponse)
async def login_user(user: UserLogin):
    try:
        return await user_crud.login(user)
    except Exception as e:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail=str(e))


@router.get("/logout", status_code=status.HTTP_204_NO_CONTENT)
async def logout_user(user_id: int):
    try:
        await user_crud.logout(user_id)
    except Exception as e:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(e))


@router.patch("/update", response_model=UserResponse)
async def update_user(user: UserUpdate):
    try:
        return await user_crud.update(user)
    except Exception as e:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(e))


@router.patch("/delete/{user_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_user(user_id: int):
    try:
        await user_crud.delete(user_id)
    except Exception as e:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(e))
