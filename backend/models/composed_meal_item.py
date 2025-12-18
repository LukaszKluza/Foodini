import uuid
from datetime import datetime
from typing import TYPE_CHECKING, Optional

from sqlalchemy import UUID, CheckConstraint, DateTime, ForeignKey, func
from sqlmodel import Column, Field, Relationship, SQLModel

from backend.models.types import FloatAsNumeric

if TYPE_CHECKING:
    from backend.models.meal_recipe_model import Meal
    from backend.models.meals_daily_summary import MealDailySummary


class ComposedMealItem(SQLModel, table=True):
    __tablename__ = "composed_meal_items"
    __table_args__ = (
        CheckConstraint("planned_calories >= 0", name="ck_planned_calories_nonnegative"),
        CheckConstraint("planned_protein >= 0", name="ck_planned_protein_nonnegative"),
        CheckConstraint("planned_fat >= 0", name="ck_planned_fat_nonnegative"),
        CheckConstraint("planned_carbs >= 0", name="ck_planned_carbs_nonnegative"),
        CheckConstraint("planned_weight >= 0", name="ck_planned_weight_nonnegative"),
    )

    id: uuid.UUID = Field(
        default_factory=uuid.uuid4, sa_column=Column(UUID(as_uuid=True), primary_key=True, unique=True, nullable=False)
    )
    meal_daily_summary_id: uuid.UUID = Field(
        sa_column=Column(
            UUID(as_uuid=True),
            ForeignKey("meal_daily_summary.id", ondelete="CASCADE"),
            nullable=False,
            index=True,
        )
    )
    meal_id: uuid.UUID = Field(
        sa_column=Column(UUID(as_uuid=True), ForeignKey("meals.id", ondelete="CASCADE"), nullable=False)
    )
    planned_calories: int = Field(nullable=False, ge=0)
    planned_protein: float = Field(sa_column=Column(FloatAsNumeric), ge=0, le=500)
    planned_fat: float = Field(sa_column=Column(FloatAsNumeric), ge=0, le=500)
    planned_carbs: float = Field(sa_column=Column(FloatAsNumeric), ge=0, le=500)
    planned_weight: int = Field(nullable=False, ge=0, le=2250)
    is_active: bool = Field(default=True, nullable=False)

    created_at: datetime = Field(sa_column=Column(DateTime(timezone=True), server_default=func.now()))
    updated_at: datetime = Field(
        sa_column=Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())
    )

    meal: Optional["Meal"] = Relationship(back_populates="composed_meal_items")
    daily_meal: Optional["MealDailySummary"] = Relationship(
        back_populates="meal_items",
        sa_relationship_kwargs={"primaryjoin": "ComposedMealItem.meal_daily_summary_id == MealDailySummary.id"},
    )
