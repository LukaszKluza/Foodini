import uuid
from datetime import datetime
from typing import TYPE_CHECKING, List, Optional

from sqlalchemy import UUID, CheckConstraint, Column, DateTime, ForeignKey, Index, func
from sqlmodel import Field, Relationship, SQLModel

from backend.meals.enums.meal_type import MealType
from backend.models.types import FloatAsNumeric

if TYPE_CHECKING:
    from backend.models.meal_icon_model import MealIcon
    from backend.models.meal_recipe_model import MealRecipe
    from backend.models.meal_type_daily_summary import ComposedMealItem


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
    icon_id: uuid.UUID = Field(sa_column=Column(UUID(as_uuid=True), ForeignKey("meal_icons.id")))
    calories: int = Field(nullable=False, ge=0)
    protein: float = Field(sa_column=Column(FloatAsNumeric), ge=0, le=500)
    fat: float = Field(sa_column=Column(FloatAsNumeric), ge=0, le=500)
    carbs: float = Field(sa_column=Column(FloatAsNumeric), ge=0, le=500)
    weight: int = Field(nullable=False, ge=0, le=2250)
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
