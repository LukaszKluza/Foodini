from datetime import date
from typing import Optional
from sqlmodel import Relationship, SQLModel, Field
from enums.gender import Gender
from enums.diet_type import DietType
from enums.diet_intensivity import DietIntensivity
from enums.activity_level import ActivityLevel
from enums.sleep_quality import SleepQuality
from enums.stress_level import StressLevel
from backend.users.models import User


class UserDetails(SQLModel, table=True):
    __tablename__ = "user_details"

    id: int = Field(default=None, primary_key=True)
    user_id: int = Field(
        foreign_key="users.id", nullable=False, sa_column_kwargs={"ondelete": "CASCADE"}
    )
    gender: Gender = Field(nullable=False)
    height_cm: float = Field(nullable=False)
    weight_kg: float = Field(nullable=False)
    date_of_birth: date = Field(nullable=False)
    diet_type: DietType = Field(nullable=False)
    allergies: str = Field(max_length=50, nullable=False)
    diet_goal_kg: float = Field(nullable=False)
    meals_per_day: int = Field(nullable=False, ge=2, le=5)
    diet_intensivity: DietIntensivity = Field(nullable=False)
    activity_level: ActivityLevel = Field(nullable=False)
    stress_level: StressLevel = Field(nullable=False)
    sleep_quality: SleepQuality = Field(nullable=False)
    muscle_percentage: float = Field(ge=0, le=100)
    water_percentage: float = Field(ge=0, le=100)
    fat_percentage: float = Field(ge=0, le=100)
    user: Optional["User"] = Relationship(back_populates="details")
