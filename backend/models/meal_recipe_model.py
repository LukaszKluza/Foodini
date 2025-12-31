import uuid
from datetime import datetime
from typing import List, Optional

from sqlalchemy import UUID, Column, DateTime, ForeignKey, Index, UniqueConstraint, func
from sqlalchemy.dialects.postgresql import JSONB
from sqlmodel import Field, Relationship, SQLModel

from backend.core.db_listeners import register_timestamp_listeners
from backend.models.meal_model import Meal
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
    __table_args__ = (
        UniqueConstraint("meal_id", "language", name="uq_recipe_meal_language"),
        Index("ix_meal_recipe_meal_id", "meal_id"),
    )

    id: uuid.UUID = Field(
        default_factory=uuid.uuid4, sa_column=Column(UUID(as_uuid=True), primary_key=True, unique=True, nullable=False)
    )
    # Can be duplicated for the same recipe but different language
    meal_id: uuid.UUID = Field(
        sa_column=Column(UUID(as_uuid=True), ForeignKey("meals.id", ondelete="CASCADE"), nullable=False)
    )
    language: Language = Field(default=Language.EN, nullable=False)
    meal_name: str = Field(nullable=False)
    meal_description: str = Field(nullable=False)
    meal_explanation: str = Field(nullable=True)
    ingredients: Ingredients = Field(sa_column=Column(JSONB, nullable=False))
    steps: List[Step] = Field(sa_column=Column(JSONB, nullable=False))
    created_at: datetime = Field(sa_column=Column(DateTime(timezone=True), server_default=func.now()))
    updated_at: datetime = Field(
        sa_column=Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())
    )

    meal: "Meal" = Relationship(back_populates="recipes", sa_relationship_kwargs={"passive_deletes": True})


register_timestamp_listeners([Meal, MealRecipe])
