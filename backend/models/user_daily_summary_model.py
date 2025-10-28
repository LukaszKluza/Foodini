import uuid
from datetime import date, datetime
from typing import TYPE_CHECKING, List, Optional

from sqlalchemy import UUID, ForeignKey
from sqlmodel import Column, DateTime, Field, Relationship, SQLModel, func

from ..diet_generation.enums.meal_status import MealStatus

if TYPE_CHECKING:
    from .meal_recipe_model import Meal
    from .user_model import User


class MealToDailySummary(SQLModel, table=True):
    __tablename__ = "meal_daily_summary"
    daily_summary_id: uuid.UUID = Field(
        sa_column=Column(
            UUID(as_uuid=True),
            ForeignKey("daily_meals_summaries.id", ondelete="CASCADE"),
            primary_key=True,
            nullable=False,
        )
    )
    meal_id: uuid.UUID = Field(
        sa_column=Column(
            UUID(as_uuid=True), ForeignKey("meals.id", ondelete="CASCADE"), primary_key=True, nullable=False
        )
    )
    status: MealStatus = Field(default=MealStatus.TO_EAT, nullable=False)

    daily_summary: Optional["DailyMealsSummary"] = Relationship(
        back_populates="daily_meals", sa_relationship_kwargs={"cascade": "all, delete"}
    )
    meal: Optional["Meal"] = Relationship(
        back_populates="daily_meals", sa_relationship_kwargs={"cascade": "all, delete", "overlaps": "daily_summary"}
    )


class DailyMealsSummary(SQLModel, table=True):
    __tablename__ = "daily_meals_summaries"

    id: uuid.UUID = Field(
        default_factory=uuid.uuid4, sa_column=Column(UUID(as_uuid=True), primary_key=True, unique=True, nullable=False)
    )
    user_id: uuid.UUID = Field(sa_column=Column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE")))
    day: date = Field(nullable=False)

    target_calories: int = Field(nullable=False)
    target_protein: int = Field(nullable=False)
    target_carbs: int = Field(nullable=False)
    target_fat: int = Field(nullable=False)

    created_at: datetime = Field(sa_column=Column(DateTime(timezone=True), server_default=func.now()))
    updated_at: datetime = Field(
        sa_column=Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())
    )

    user: Optional["User"] = Relationship(
        back_populates="daily_meals_summaries", sa_relationship_kwargs={"cascade": "all, delete"}
    )
    daily_meals: List["MealToDailySummary"] = Relationship(back_populates="daily_summary", cascade_delete=True)
    meals: List["Meal"] = Relationship(
        back_populates="daily_summary",
        link_model=MealToDailySummary,
        sa_relationship_kwargs={"overlaps": "daily_meals,daily_summary,meal"},
    )


class DailyMacrosSummary(SQLModel, table=True):
    __tablename__ = "daily_macros_summaries"

    id: uuid.UUID = Field(
        default_factory=uuid.uuid4, sa_column=Column(UUID(as_uuid=True), primary_key=True, unique=True, nullable=False)
    )
    user_id: uuid.UUID = Field(sa_column=Column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE")))
    day: date = Field(nullable=False)

    calories: int = Field(default=0, nullable=False)
    protein: int = Field(default=0, nullable=False)
    carbs: int = Field(default=0, nullable=False)
    fat: int = Field(default=0, nullable=False)

    created_at: datetime = Field(sa_column=Column(DateTime(timezone=True), server_default=func.now()))
    updated_at: datetime = Field(
        sa_column=Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())
    )

    user: Optional["User"] = Relationship(
        back_populates="daily_macros_summaries", sa_relationship_kwargs={"cascade": "all, delete"}
    )
