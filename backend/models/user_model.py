from datetime import datetime
from typing import TYPE_CHECKING, List, Optional

from pydantic import EmailStr
from sqlalchemy import Column, DateTime, func
from sqlmodel import Field, Relationship, SQLModel

from backend.settings import config
from backend.users.enums.language import Language

if TYPE_CHECKING:
    from .user_daily_summary_model import DailyMacrosSummary, DailyMeals
    from .user_details_model import UserDetails
    from .user_diet_prediction_model import UserDietPredictions


class User(SQLModel, table=True):
    __tablename__ = "users"

    id: int = Field(default=None, primary_key=True)
    name: str
    last_name: str
    country: str
    email: EmailStr = Field(unique=True, nullable=False)
    language: Language = Field(default=Language.EN)
    is_verified: bool = Field(default=False)
    password: str
    last_password_update: datetime = Field(
        default_factory=lambda: datetime.now(config.TIMEZONE),
        sa_column=Column(DateTime(timezone=True)),
    )

    details: Optional["UserDetails"] = Relationship(back_populates="user", cascade_delete=True)
    diet_predictions: Optional["UserDietPredictions"] = Relationship(back_populates="user", cascade_delete=True)
    daily_meals: List["DailyMeals"] = Relationship(back_populates="user", cascade_delete=True)
    daily_macros_summaries: List["DailyMacrosSummary"] = Relationship(back_populates="user", cascade_delete=True)

    created_at: datetime = Field(sa_column=Column(DateTime(timezone=True), server_default=func.now()))
    updated_at: datetime = Field(
        sa_column=Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())
    )
