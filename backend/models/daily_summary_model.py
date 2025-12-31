import uuid
from datetime import date, datetime
from typing import TYPE_CHECKING, List, Optional

from sqlalchemy import UUID, CheckConstraint, ForeignKey, Index, UniqueConstraint
from sqlmodel import Column, DateTime, Field, Relationship, SQLModel, func

from ..core.db_listeners import register_timestamp_listeners
from .meal_type_daily_summary import MealTypeDailySummary
from .types import FloatAsNumeric

if TYPE_CHECKING:
    from .user_model import User


class DailySummary(SQLModel, table=True):
    __tablename__ = "daily_summaries"
    __table_args__ = (
        UniqueConstraint("day", "user_id", name="uq_daily_meals_user_day"),
        Index("ix_daily_meals_user_day", "user_id", "day"),
        CheckConstraint("target_calories >= 0", name="ck_target_calories_nonnegative"),
        CheckConstraint("target_protein >= 0", name="ck_target_protein_nonnegative"),
        CheckConstraint("target_carbs >= 0", name="ck_target_carbs_nonnegative"),
        CheckConstraint("target_fat >= 0", name="ck_target_fat_nonnegative"),
    )

    id: uuid.UUID = Field(
        default_factory=uuid.uuid4, sa_column=Column(UUID(as_uuid=True), primary_key=True, unique=True, nullable=False)
    )
    user_id: uuid.UUID = Field(sa_column=Column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE")))
    day: date = Field(nullable=False)

    target_calories: int = Field(nullable=False, ge=0)
    target_protein: float = Field(sa_column=Column(FloatAsNumeric, nullable=False), ge=0)
    target_carbs: float = Field(sa_column=Column(FloatAsNumeric, nullable=False), ge=0)
    target_fat: float = Field(sa_column=Column(FloatAsNumeric, nullable=False), ge=0)

    created_at: datetime = Field(sa_column=Column(DateTime(timezone=True), server_default=func.now()))
    updated_at: datetime = Field(
        sa_column=Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())
    )

    user: Optional["User"] = Relationship(
        back_populates="daily_meals_summaries", sa_relationship_kwargs={"passive_deletes": True}
    )
    daily_meals: List["MealTypeDailySummary"] = Relationship(
        back_populates="daily_summary", sa_relationship_kwargs={"cascade": "all, delete-orphan"}
    )


register_timestamp_listeners([DailySummary])
