import uuid
from datetime import datetime
from typing import TYPE_CHECKING, List, Optional

from sqlalchemy import UUID, DateTime, ForeignKey, func
from sqlmodel import Column, Field, Relationship, SQLModel

from ..daily_summary.enums.meal_status import MealStatus
from ..meals.enums.meal_type import MealType

if TYPE_CHECKING:
    from .meal_recipe_model import Meal
    from .user_daily_summary_model import DailyMealsSummary


class MealDailySummary(SQLModel, table=True):
    __tablename__ = "meal_daily_summary"

    id: uuid.UUID = Field(
        default_factory=uuid.uuid4, sa_column=Column(UUID(as_uuid=True), primary_key=True, unique=True, nullable=False)
    )
    daily_summary_id: uuid.UUID = Field(
        sa_column=Column(
            UUID(as_uuid=True),
            ForeignKey("daily_meals_summaries.id", ondelete="CASCADE"),
            nullable=False,
        )
    )
    status: MealStatus = Field(default=MealStatus.TO_EAT, nullable=False)
    meal_type: MealType = Field(nullable=False)
    is_active: bool = Field(default=True, nullable=False)
    is_generated: bool = Field(default=True, nullable=False)

    created_at: datetime = Field(sa_column=Column(DateTime(timezone=True), server_default=func.now()))
    updated_at: datetime = Field(
        sa_column=Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())
    )

    daily_summary: Optional["DailyMealsSummary"] = Relationship(
        back_populates="daily_meals", sa_relationship_kwargs={"passive_deletes": True}
    )
    meal_items: List["ComposedMealItem"] = Relationship(
        back_populates="daily_meal",
        sa_relationship_kwargs={"primaryjoin": "ComposedMealItem.meal_daily_summary_id==MealDailySummary.id"},
    )


class ComposedMealItem(SQLModel, table=True):
    __tablename__ = "composed_meal_items"

    meal_daily_summary_id: uuid.UUID = Field(
        sa_column=Column(
            UUID(as_uuid=True),
            ForeignKey("meal_daily_summary.id", ondelete="CASCADE"),
            primary_key=True,
            nullable=False,
            index=True,
        )
    )

    meal_id: uuid.UUID = Field(
        sa_column=Column(
            UUID(as_uuid=True), ForeignKey("meals.id", ondelete="CASCADE"), primary_key=True, nullable=False
        )
    )

    weight_eaten: int = Field(nullable=False, ge=0, le=1250)

    created_at: datetime = Field(sa_column=Column(DateTime(timezone=True), server_default=func.now()))
    updated_at: datetime = Field(
        sa_column=Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())
    )

    meal: Optional["Meal"] = Relationship(back_populates="composed_meal_items")
    daily_meal: Optional["MealDailySummary"] = Relationship(
        back_populates="meal_items",
        sa_relationship_kwargs={"primaryjoin": "ComposedMealItem.meal_daily_summary_id == MealDailySummary.id"},
    )
