import uuid
from datetime import datetime
from typing import TYPE_CHECKING, List, Optional

from sqlalchemy import (
    UUID,
    CheckConstraint,
    Column,
    DateTime,
    ForeignKey,
    Index,
    UniqueConstraint,
    func,
)
from sqlalchemy.dialects.postgresql import JSONB
from sqlmodel import Field, Relationship, SQLModel

from backend.meals.enums.meal_type import MealType
from backend.models.meals_daily_summary import ComposedMealItem
from backend.users.enums.language import Language

from ..core.db_listeners import register_timestamp_listeners
from .types import FloatAsNumeric

if TYPE_CHECKING:
    from .meal_icon_model import MealIcon


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


class Meal(SQLModel, table=True):
    __tablename__ = "meals"
    __table_args__ = (
        Index("ix_meal_type", "meal_type"),
        CheckConstraint("calories >= 0", name="ck_calories_nonnegative"),
        CheckConstraint("protein >= 0", name="ck_protein_nonnegative"),
        CheckConstraint("carbs >= 0", name="ck_carbs_nonnegative"),
        CheckConstraint("fat >= 0", name="ck_fat_nonnegative"),
        CheckConstraint("weight >= 0", name="ck_weight_nonnegative"),
    )

    id: uuid.UUID = Field(
        default_factory=uuid.uuid4, sa_column=Column(UUID(as_uuid=True), primary_key=True, unique=True, nullable=False)
    )
    meal_name: str = Field(nullable=False)
    meal_type: MealType = Field(nullable=False)
    icon_id: uuid.UUID = Field(sa_column=Column(UUID(as_uuid=True), ForeignKey("meal_icons.id"), nullable=False))
    calories: int = Field(nullable=False, ge=0)
    protein: float = Field(sa_column=Column(FloatAsNumeric), ge=0)
    fat: float = Field(sa_column=Column(FloatAsNumeric), ge=0)
    carbs: float = Field(sa_column=Column(FloatAsNumeric), ge=0)
    weight: int = Field(nullable=False, ge=0, le=1250)
    is_generated: bool = Field(default=True, nullable=False)
    created_at: datetime = Field(sa_column=Column(DateTime(timezone=True), server_default=func.now()))
    updated_at: datetime = Field(
        sa_column=Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())
    )

    recipes: List["MealRecipe"] = Relationship(
        back_populates="meal", sa_relationship_kwargs={"cascade": "all, delete-orphan"}
    )
    icon: Optional["MealIcon"] = Relationship(back_populates="meals", sa_relationship_kwargs={"cascade": "save-update"})
    composed_meal_items: List["ComposedMealItem"] = Relationship(
        back_populates="meal", sa_relationship_kwargs={"cascade": "all, delete-orphan", "passive_deletes": True}
    )


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
