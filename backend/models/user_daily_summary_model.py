from datetime import datetime, date
from typing import TYPE_CHECKING, List, Optional
from sqlalchemy import Column, DateTime, func
from sqlmodel import SQLModel, Field, Relationship

from backend.diet_prediction.enums.meal_status import MealStatus

if TYPE_CHECKING:
    from .meal_model import Meal


class UserDailySummary(SQLModel, table=True):
    __tablename__ = "user_daily_summary"

    id: int = Field(default=None, primary_key=True)
    user_id: int = Field(foreign_key="users.id", nullable=False)
    day: date = Field(nullable=False, index=True)

    meal_items: List["UserDailyMealItem"] = Relationship(back_populates="daily_meals")
    next_meal: Optional[int] = Field(nullable=True) # When created set this to first meal id

    calories_consumed: int = Field(default=0, nullable=False)
    protein_consumed: int = Field(default=0, nullable=False)
    fat_consumed: int = Field(default=0, nullable=False)
    carbs_consumed: int = Field(default=0, nullable=False)

    created_at: datetime = Field(sa_column=Column(DateTime(timezone=True), server_default=func.now()))
    updated_at: datetime = Field(
        sa_column=Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())
    )


class UserDailyMealItem(SQLModel, table=True):
    __tablename__ = "user_daily_meal_items"

    id: int = Field(default=None, primary_key=True)
    daily_meals_id: int = Field(foreign_key="user_daily_summary.id", nullable=False)
    meal_id: int = Field(foreign_key="meals.id", nullable=False)
    status: MealStatus = Field(default=MealStatus.PENDING, nullable=False)

    daily_meals: Optional["UserDailySummary"] = Relationship(back_populates="meal_items")
    meal: Optional["Meal"] = Relationship()
