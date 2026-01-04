import uuid
from datetime import datetime
from typing import TYPE_CHECKING, List, Optional

from sqlalchemy import UUID, DateTime, ForeignKey, func
from sqlmodel import Column, Field, Relationship, SQLModel

from backend.daily_summary.enums.meal_status import MealStatus
from backend.meals.enums.meal_type import MealType

if TYPE_CHECKING:
    from backend.models.composed_meal_item_model import ComposedMealItem
    from backend.models.daily_summary_model import DailySummary


class MealTypeDailySummary(SQLModel, table=True):
    __tablename__ = "meal_type_daily_summary"

    id: uuid.UUID = Field(
        default_factory=uuid.uuid4, sa_column=Column(UUID(as_uuid=True), primary_key=True, unique=True, nullable=False)
    )
    daily_summary_id: uuid.UUID = Field(
        sa_column=Column(
            UUID(as_uuid=True),
            ForeignKey("daily_summaries.id", ondelete="CASCADE"),
            nullable=False,
        )
    )
    status: MealStatus = Field(default=MealStatus.TO_EAT, nullable=False)
    meal_type: MealType = Field(nullable=False)

    created_at: datetime = Field(sa_column=Column(DateTime(timezone=True), server_default=func.now()))
    updated_at: datetime = Field(
        sa_column=Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())
    )

    daily_summary: Optional["DailySummary"] = Relationship(
        back_populates="daily_meals", sa_relationship_kwargs={"passive_deletes": True}
    )
    meal_items: List["ComposedMealItem"] = Relationship(
        back_populates="daily_meal",
        sa_relationship_kwargs={"primaryjoin": "ComposedMealItem.meal_type_daily_summary_id==MealTypeDailySummary.id"},
    )
