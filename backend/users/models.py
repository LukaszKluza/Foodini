from pydantic import EmailStr
from datetime import datetime
from sqlmodel import SQLModel, Field
from sqlalchemy import DateTime

from backend.settings import config


class User(SQLModel, table=True):
    __tablename__ = "users"

    id: int = Field(default=None, primary_key=True)
    name: str = Field(nullable=False)
    last_name: str = Field(nullable=False)
    age: int = Field(nullable=False)
    country: str = Field(nullable=False)
    email: EmailStr = Field(unique=True, nullable=False)
    is_verified: bool = Field(nullable=False, default=False)
    password: str = Field(nullable=False)
    last_password_update: datetime = Field(
        default_factory=lambda: datetime.now(config.TIMEZONE),
        sa_type=DateTime(timezone=True),
    )
