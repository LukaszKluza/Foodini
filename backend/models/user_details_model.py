from typing import List, Optional, TYPE_CHECKING
from datetime import date
from sqlmodel import SQLModel, Field, Relationship
from sqlalchemy import ARRAY, Column, Integer, ForeignKey, Enum
from backend.user_details.enums import (
    ActivityLevel,
    Allergies,
    DietIntensity,
    DietType,
    Gender,
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
            Integer,
            ForeignKey("users.id", ondelete="CASCADE"),
            nullable=False,
            unique=True,
        )
    )
    user: Optional["User"] = Relationship(back_populates="details")
    gender: Gender = Field(nullable=False)
    height_cm: float = Field(ge=50, le=230)
    weight_kg: float = Field(ge=20, le=160)
    date_of_birth: date
    diet_type: DietType = Field(nullable=False)
    allergies: List[Allergies] = Field(
        sa_column=Column(ARRAY(Enum(Allergies))), default=[]
    )
    diet_goal_kg: float
    meals_per_day: int = Field(ge=2, le=5)
    diet_intensity: DietIntensity = Field(nullable=False)
    activity_level: ActivityLevel = Field(nullable=False)
    stress_level: StressLevel = Field(nullable=False)
    sleep_quality: SleepQuality = Field(nullable=False)
    muscle_percentage: Optional[float] = Field(default=None, ge=0, le=100)
    water_percentage: Optional[float] = Field(default=None, ge=0, le=100)
    fat_percentage: Optional[float] = Field(default=None, ge=0, le=100)
