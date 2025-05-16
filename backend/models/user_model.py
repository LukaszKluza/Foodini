from datetime import datetime
from typing import Optional, TYPE_CHECKING
from sqlmodel import SQLModel, Field, Relationship
from sqlalchemy import DateTime
from backend.settings import config

if TYPE_CHECKING:
    from .user_details_model import UserDetails


class User(SQLModel, table=True):
    __tablename__ = "users"

    id: int = Field(default=None, primary_key=True)
    name: str
    last_name: str
    country: str
    email: str = Field(unique=True, nullable=False)
    is_verified: bool = Field(default=False)
    password: str
    last_password_update: datetime = Field(
        default_factory=lambda: datetime.now(config.TIMEZONE),
        sa_type=DateTime(timezone=True),
    )

    details: Optional["UserDetails"] = Relationship(back_populates="user")
