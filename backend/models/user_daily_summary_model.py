from datetime import date, datetime
from typing import Dict

from sqlalchemy import JSON
from sqlmodel import Column, DateTime, Field, SQLModel, func


class DailyMeals(SQLModel, table=True):
    __tablename__ = "daily_meals"

    id: int = Field(default=None, primary_key=True)
    user_id: int = Field(foreign_key="users.id")
    meals: Dict[str, Dict[str, str]] = Field(sa_column=Column(JSON))
    day: date = Field(nullable=False)

    created_at: datetime = Field(sa_column=Column(DateTime(timezone=True), server_default=func.now()))
    updated_at: datetime = Field(
        sa_column=Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())
    )


class DailyMacrosSummary(SQLModel, table=True):
    __tablename__ = "daily_macros_summaries"

    id: int = Field(default=None, primary_key=True)
    user_id: int = Field(foreign_key="users.id")
    day: date = Field(nullable=False)

    calories: int = Field(default=0, nullable=False)
    protein: int = Field(default=0, nullable=False)
    carbs: int = Field(default=0, nullable=False)
    fats: int = Field(default=0, nullable=False)

    created_at: datetime = Field(sa_column=Column(DateTime(timezone=True), server_default=func.now()))
    updated_at: datetime = Field(
        sa_column=Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())
    )
