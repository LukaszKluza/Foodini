from datetime import datetime
from typing import List, Optional
from uuid import UUID

from pydantic import BaseModel, EmailStr, Field

from ..models.user_model import Language
from .enums.role import Role
from .enums.token import Token
from .mixins import CountryValidationMixin, PasswordValidationMixin


class UserCreate(PasswordValidationMixin, CountryValidationMixin, BaseModel):
    name: str = Field(..., min_length=2, max_length=50, pattern="^[a-zA-Z]+$")
    last_name: str = Field(..., min_length=2, max_length=50, pattern="^[a-zA-Z-]+$")
    country: str = Field(..., min_length=2, max_length=50)
    email: EmailStr
    password: str = Field(..., min_length=8, max_length=64)
    language: Language


class PasswordResetRequest(BaseModel):
    email: EmailStr


class ChangeLanguageRequest(BaseModel):
    language: Language


class NewPasswordConfirm(PasswordValidationMixin, BaseModel):
    email: EmailStr
    password: str = Field(..., min_length=8, max_length=64)
    token: str


class UserUpdate(CountryValidationMixin, BaseModel):
    name: Optional[str] = Field(None, min_length=2, max_length=50, pattern="^[a-zA-Z]+$")
    last_name: Optional[str] = Field(None, min_length=2, max_length=50, pattern="^[a-zA-Z-]+$")
    country: Optional[str] = Field(None, min_length=2, max_length=50)


class UserLogin(PasswordValidationMixin, BaseModel):
    email: EmailStr
    password: str = Field(..., min_length=8, max_length=64)


class UserLogout(BaseModel):
    id: UUID
    email: EmailStr


class DefaultResponse(BaseModel):
    id: UUID
    email: EmailStr


class UserResponse(DefaultResponse):
    id: UUID
    name: str
    email: EmailStr
    language: Language


class LoginUserResponse(DefaultResponse):
    id: UUID
    email: EmailStr
    access_token: str
    refresh_token: str


class RefreshTokensResponse(DefaultResponse):
    access_token: str
    refresh_token: str


class EmailSchema(BaseModel):
    addresses: List[EmailStr]


class TokenPayload(DefaultResponse):
    jti: str
    linked_jti: str
    exp: datetime
    type: Token
    role: Role
