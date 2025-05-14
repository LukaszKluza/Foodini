from typing import Optional, TYPE_CHECKING
from datetime import date
from sqlmodel import SQLModel, Field, Relationship
from sqlalchemy import Column, Integer, ForeignKey
from backend.user_details.enums import (
    Gender,
    DietType,
    DietIntensivity,
    ActivityLevel,
    SleepQuality,
    StressLevel,
)

if TYPE_CHECKING:
    from .user_model import User


class UserDetails(SQLModel, table=True):
    __tablename__ = "user_details"

    id: int = Field(default=None, primary_key=True)
    user_id: int = Field(
        sa_column=Column(
            Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False
        )
    )
    gender: Gender
    height_cm: float
    weight_kg: float
    date_of_birth: date
    diet_type: DietType
    allergies: str = Field(max_length=50)
    diet_goal_kg: float
    meals_per_day: int = Field(ge=2, le=5)
    diet_intensivity: DietIntensivity
    activity_level: ActivityLevel
    stress_level: StressLevel
    sleep_quality: SleepQuality
    muscle_percentage: float = Field(ge=0, le=100)
    water_percentage: float = Field(ge=0, le=100)
    fat_percentage: float = Field(ge=0, le=100)

    user: Optional["User"] = Relationship(back_populates="details")
