from typing import List, Optional, TYPE_CHECKING
from datetime import date
from sqlmodel import SQLModel, Field, Relationship
from sqlalchemy import Column, Integer, ForeignKey
from .user_properties_models import (
    Gender,
    DietType,
    DietIntensity,
    ActivityLevel,
    StressLevel,
    SleepQuality,
    Allergies,
    AllergyLink,
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

    gender_id: int = Field(foreign_key="gender.id")
    gender: Optional["Gender"] = Relationship()

    height_cm: float = Field(ge=50, le=230)
    weight_kg: float = Field(ge=20, le=160)
    date_of_birth: date

    diet_type_id: int = Field(foreign_key="diet_type.id")
    diet_type: Optional["DietType"] = Relationship()

    allergies: List["Allergies"] = Relationship(
        back_populates="user_details", link_model=AllergyLink
    )

    diet_goal_kg: float
    meals_per_day: int = Field(ge=2, le=6)

    diet_intensity_id: int = Field(foreign_key="diet_intensity.id")
    diet_intensity: Optional["DietIntensity"] = Relationship()

    activity_level_id: int = Field(foreign_key="activity_level.id")
    activity_level: Optional["ActivityLevel"] = Relationship()

    stress_level_id: int = Field(foreign_key="stress_level.id")
    stress_level: Optional["StressLevel"] = Relationship()

    sleep_quality_id: int = Field(foreign_key="sleep_quality.id")
    sleep_quality: Optional["SleepQuality"] = Relationship()

    muscle_percentage: float = Field(ge=0, le=100)
    water_percentage: float = Field(ge=0, le=100)
    fat_percentage: float = Field(ge=0, le=100)
