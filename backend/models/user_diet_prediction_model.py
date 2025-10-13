from datetime import datetime
from typing import TYPE_CHECKING, Optional

from sqlalchemy import Column, DateTime, ForeignKey, Integer, func
from sqlmodel import Field, Relationship, SQLModel

if TYPE_CHECKING:
    from .user_model import User


class UserDietPredictions(SQLModel, table=True):
    __tablename__ = "user_diet_predictions"

    id: int = Field(default=None, primary_key=True)
    user_id: int = Field(
        sa_column=Column(
            Integer,
            ForeignKey("users.id", ondelete="CASCADE"),
            nullable=False,
            unique=True,
        )
    )
    user: Optional["User"] = Relationship(back_populates="diet_predictions")
    protein: int = Field(ge=0)
    fat: int = Field(ge=0)
    carbs: int = Field(ge=0)
    bmr: int = Field(ge=0)
    tdee: int = Field(ge=0)
    target_calories: int = Field(ge=0)
    diet_duration_days: Optional[int] = None

    created_at: datetime = Field(sa_column=Column(DateTime(timezone=True), server_default=func.now()))
    updated_at: datetime = Field(
        sa_column=Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())
    )
