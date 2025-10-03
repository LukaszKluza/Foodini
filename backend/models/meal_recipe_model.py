from datetime import datetime
from typing import List, Optional

from sqlalchemy import Column, DateTime, func
from sqlalchemy.dialects.postgresql import JSONB
from sqlmodel import Field, SQLModel

from backend.diet_prediction.enums.meal_type import MealType
from backend.users.enums.language import Language


class Ingredient(SQLModel):
    volume: float
    unit: str
    name: str
    optional_note: Optional[str] = None


class Ingredients(SQLModel):
    ingredients: List[Ingredient]
    food_additives: Optional[str] = None


class Step(SQLModel):
    description: str
    optional: bool = False


class MealRecipe(SQLModel, table=True):
    __tablename__ = "meal_recipes"

    id: int = Field(default=None, primary_key=True)
    # Can be duplicated for the same recipe but different language
    meal_id: int = Field(nullable=False, index=True)
    language: Language = Field(default=Language.EN, nullable=False)
    meal_name: str = Field(nullable=False)
    meal_type: MealType = Field(nullable=False)
    meal_description: str = Field(nullable=False)
    icon_id: int = Field(nullable=False)
    ingredients: Ingredients = Field(sa_column=Column(JSONB, nullable=False))
    steps: List[Step] = Field(sa_column=Column(JSONB, nullable=False))
    created_at: datetime = Field(sa_column=Column(DateTime(timezone=True), server_default=func.now()))
    updated_at: datetime = Field(
        sa_column=Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())
    )
