from pydantic import BaseModel, EmailStr, Field, field_validator
from typing import Optional
import re


class UserCreate(BaseModel):
    name: str = Field(..., min_length=2, max_length=50, pattern="^[a-zA-Z]+$")
    last_name: str = Field(..., min_length=2, max_length=50, pattern="^[a-zA-Z-]+$")
    age: int = Field(..., gt=12, lt=120)
    country: str = Field(..., min_length=2, max_length=50)
    email: EmailStr
    password: str = Field(..., min_length=8, max_length=64)

    @field_validator("password")
    def password_complexity(cls, v):
        if not re.search(r"[A-Z]", v):
            raise ValueError("Password must contain at least one uppercase letter")
        if not re.search(r"[a-z]", v):
            raise ValueError("Password must contain at least one lowercase letter")
        if not re.search(r"[0-9]", v):
            raise ValueError("Password must contain at least one digit")
        return v


class UserUpdate(BaseModel):
    user_id: int = Field(..., gt=0)
    name: Optional[str] = Field(
        None, min_length=2, max_length=50, pattern="^[a-zA-Z]+$"
    )
    last_name: Optional[str] = Field(
        None, min_length=2, max_length=50, pattern="^[a-zA-Z-]+$"
    )
    age: Optional[int] = Field(None, gt=12, lt=120)
    country: Optional[str] = Field(None, min_length=2, max_length=50)


class UserLogin(BaseModel):
    email: EmailStr
    password: str = Field(..., min_length=8, max_length=64)

    @field_validator("password")
    def password_complexity(cls, v):
        if not re.search(r"[A-Z]", v):
            raise ValueError("Password must contain at least one uppercase letter")
        if not re.search(r"[a-z]", v):
            raise ValueError("Password must contain at least one lowercase letter")
        if not re.search(r"[0-9]", v):
            raise ValueError("Password must contain at least one digit")
        return v


class UserLogout(BaseModel):
    id: int = Field(..., gt=0)
    email: EmailStr


class UserResponse(BaseModel):
    id: int = Field(..., gt=0)
    email: EmailStr
