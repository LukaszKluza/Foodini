from datetime import date, datetime
from typing import TYPE_CHECKING, Dict, Optional

from sqlalchemy import JSON
from sqlalchemy.ext.mutable import MutableDict
from sqlmodel import Column, DateTime, Field, Relationship, SQLModel, func

if TYPE_CHECKING:
    from .user_model import User


class DailyMeals(SQLModel, table=True):
    __tablename__ = "daily_meals"

    id: int = Field(default=None, primary_key=True)
    user_id: int = Field(foreign_key="users.id", ondelete="CASCADE")
    meals: Dict[str, Dict[str, str]] = Field(sa_column=Column(MutableDict.as_mutable(JSON)))
    day: date = Field(nullable=False)

    target_calories: int = Field(nullable=False)
    target_protein: int = Field(nullable=False)
    target_carbs: int = Field(nullable=False)
    target_fat: int = Field(nullable=False)

    created_at: datetime = Field(sa_column=Column(DateTime(timezone=True), server_default=func.now()))
    updated_at: datetime = Field(
        sa_column=Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())
    )

    user: Optional["User"] = Relationship(back_populates="daily_meals")


class DailyMacrosSummary(SQLModel, table=True):
    __tablename__ = "daily_macros_summaries"

    id: int = Field(default=None, primary_key=True)
    user_id: int = Field(foreign_key="users.id", ondelete="CASCADE")
    day: date = Field(nullable=False)

    calories: int = Field(default=0, nullable=False)
    protein: int = Field(default=0, nullable=False)
    carbs: int = Field(default=0, nullable=False)
    fat: int = Field(default=0, nullable=False)

    created_at: datetime = Field(sa_column=Column(DateTime(timezone=True), server_default=func.now()))
    updated_at: datetime = Field(
        sa_column=Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())
    )

    user: Optional["User"] = Relationship(back_populates="daily_macros_summaries")
