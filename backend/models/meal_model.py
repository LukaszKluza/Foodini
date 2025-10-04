from datetime import datetime
from typing import TYPE_CHECKING, Optional

from sqlalchemy import Column, DateTime, func
from sqlmodel import Field, Relationship, SQLModel

from backend.diet_prediction.enums.meal_type import MealType

if TYPE_CHECKING:
    from .meal_icon_model import MealIcon


class Meal(SQLModel, table=True):
    __tablename__ = "meals"

    id: int = Field(default=None, primary_key=True)
    name: str = Field(nullable=False, index=True)
    description: Optional[str] = Field(default=None)
    recipe: Optional[str] = Field(default=None)
    meal_type: MealType = Field(nullable=False, unique=True)
    meal_icon_id: int = Field(foreign_key="meal_icons.id", nullable=False)
    meal_icon: Optional["MealIcon"] = Relationship()

    calories: int = Field(nullable=False)
    protein: float = Field(nullable=False)
    fat: float = Field(nullable=False)
    carbs: float = Field(nullable=False)

    created_at: datetime = Field(sa_column=Column(DateTime(timezone=True), server_default=func.now()))
    updated_at: datetime = Field(
        sa_column=Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())
    )
