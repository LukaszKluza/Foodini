from pydantic import BaseModel, EmailStr, Field
from typing import Optional


class UserCreate(BaseModel):
    name: str = Field(..., min_length=2, max_length=50, regex="^[a-zA-Z]+$")
    last_name: str = Field(..., min_length=2, max_length=50, regex="^[a-zA-Z-]+$")
    age: int = Field(..., gt=12, lt=120)
    country: str = Field(..., min_length=2, max_length=50)
    email: EmailStr
    password: str


class UserUpdate(BaseModel):
    user_id: int = Field(..., gt=0)
    name: Optional[str] = Field(None, min_length=2, max_length=50, regex="^[a-zA-Z]+$")
    last_name: Optional[str] = Field(
        None, min_length=2, max_length=50, regex="^[a-zA-Z-]+$"
    )
    age: Optional[int] = Field(None, gt=12, lt=120)
    country: Optional[str] = Field(None, min_length=2, max_length=50)


class UserLogin(BaseModel):
    email: EmailStr
    password: str


class UserLogout(BaseModel):
    id: int = Field(..., gt=0)
    email: EmailStr


class UserResponse(BaseModel):
    id: int = Field(..., gt=0)
    email: EmailStr
