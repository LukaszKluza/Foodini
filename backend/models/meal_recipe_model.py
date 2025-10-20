from datetime import datetime
from typing import List, Optional

from sqlalchemy import Column, DateTime, func
from sqlalchemy.dialects.postgresql import JSONB
from sqlmodel import Field, SQLModel

from backend.diet_generation.enums.meal_type import MealType
from backend.users.enums.language import Language


class Ingredient(SQLModel):
    volume: float = Field(..., nullable=False, ge=0.001, le=10000)
    unit: str = Field(..., nullable=False, min_length=1, max_length=20)
    name: str = Field(..., nullable=False, min_length=2, max_length=100)
    optional_note: Optional[str] = Field(None, max_length=200)


class Ingredients(SQLModel):
    ingredients: List[Ingredient] = Field(..., min_items=1, max_items=25)
    food_additives: Optional[str] = Field(None, max_length=200)


class Step(SQLModel):
    description: str = Field(..., nullable=False, min_length=5, max_length=1500)
    optional: bool = False


class Meal(SQLModel, table=True):
    __tablename__ = "meal"

    id: int = Field(default=None, primary_key=True)
    meal_name: str = Field(..., nullable=False, min_length=2, max_length=100)
    meal_type: MealType = Field(nullable=False)
    icon_id: int = Field(nullable=False)
    calories: int = Field(nullable=False, ge=0, le=2000)
    protein: int = Field(nullable=False, ge=0, le=100)
    fat: int = Field(nullable=False, ge=0, le=100)
    carbs: int = Field(nullable=False, ge=0, le=100)
    created_at: datetime = Field(sa_column=Column(DateTime(timezone=True), server_default=func.now()))
    updated_at: datetime = Field(
        sa_column=Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())
    )


class MealRecipe(SQLModel, table=True):
    __tablename__ = "meal_recipes"

    id: int = Field(default=None, primary_key=True)
    # Can be duplicated for the same recipe but different language
    meal_id: int = Field(nullable=False, index=True)
    language: Language = Field(default=Language.EN, nullable=False)
    meal_description: str = Field(nullable=False)
    ingredients: Ingredients = Field(sa_column=Column(JSONB, nullable=False))
    steps: List[Step] = Field(sa_column=Column(JSONB, nullable=False), min_items=1, max_items=25)
    created_at: datetime = Field(sa_column=Column(DateTime(timezone=True), server_default=func.now()))
    updated_at: datetime = Field(
        sa_column=Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())
    )
