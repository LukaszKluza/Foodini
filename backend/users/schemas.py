from pydantic import BaseModel, EmailStr, Field
from typing import Optional
from .mixins import PasswordValidationMixin, CountryValidationMixin


class UserCreate(PasswordValidationMixin, CountryValidationMixin, BaseModel):
    name: str = Field(..., min_length=2, max_length=50, pattern="^[a-zA-Z]+$")
    last_name: str = Field(..., min_length=2, max_length=50, pattern="^[a-zA-Z-]+$")
    age: int = Field(..., gt=12, lt=120)
    country: str = Field(..., min_length=2, max_length=50)
    email: EmailStr
    password: str = Field(..., min_length=8, max_length=64)


class PasswordResetRequest(PasswordValidationMixin, BaseModel):
    email: EmailStr
    password: str = Field(..., min_length=8, max_length=64)


class UserUpdate(CountryValidationMixin, BaseModel):
    name: Optional[str] = Field(
        None, min_length=2, max_length=50, pattern="^[a-zA-Z]+$"
    )
    last_name: Optional[str] = Field(
        None, min_length=2, max_length=50, pattern="^[a-zA-Z-]+$"
    )
    age: Optional[int] = Field(None, gt=12, lt=120)
    country: Optional[str] = Field(None, min_length=2, max_length=50)


class UserLogin(PasswordValidationMixin, BaseModel):
    email: EmailStr
    password: str = Field(..., min_length=8, max_length=64)


class UserLogout(BaseModel):
    id: int = Field(..., gt=0)
    email: EmailStr


class UserResponse(BaseModel):
    id: int = Field(..., gt=0)
    email: EmailStr


class LoginUserResponse(UserResponse):
    id: int
    email: EmailStr
    access_token: str
    refresh_token: str
