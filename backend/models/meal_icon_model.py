from datetime import datetime

from sqlalchemy import Column, DateTime, func
from sqlmodel import Field, SQLModel

from backend.meals.enums.meal_type import MealType


class MealIcon(SQLModel, table=True):
    __tablename__ = "meal_icons"

    id: int = Field(default=None, primary_key=True)
    meal_type: MealType = Field(nullable=False, unique=True)
    icon_path: str = Field(nullable=False)
    created_at: datetime = Field(sa_column=Column(DateTime(timezone=True), server_default=func.now()))
    updated_at: datetime = Field(
        sa_column=Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())
    )
