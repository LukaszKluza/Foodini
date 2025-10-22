from datetime import datetime
from typing import TYPE_CHECKING, List

from sqlalchemy import Column, DateTime, func
from sqlmodel import Field, Relationship, SQLModel

from backend.diet_generation.enums.meal_type import MealType

if TYPE_CHECKING:
    from .meal_recipe_model import Meal


class MealIcon(SQLModel, table=True):
    __tablename__ = "meal_icons"

    id: int = Field(default=None, primary_key=True)
    meal_type: MealType = Field(nullable=False, unique=True)
    icon_path: str = Field(nullable=False)
    created_at: datetime = Field(sa_column=Column(DateTime(timezone=True), server_default=func.now()))
    updated_at: datetime = Field(
        sa_column=Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())
    )

    meals: List["Meal"] = Relationship(back_populates="icon")
