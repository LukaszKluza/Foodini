from datetime import date
from pydantic import BaseModel, Field
from typing import List, Optional
from .enums import (
    Gender,
    DietType,
    DietIntensity,
    ActivityLevel,
    SleepQuality,
    StressLevel,
    Allergies,
)
from .mixins import DateOfBirthValidationMixin


class UserDetailsCreate(DateOfBirthValidationMixin, BaseModel):
    user_id: int
    gender: Gender
    height_cm: float = Field(..., ge=50, le=300)
    weight_kg: float = Field(..., ge=20, le=400)
    date_of_birth: date
    diet_type: DietType
    allergies: List[Allergies]
    diet_goal_kg: float = Field(..., ge=20, le=400)
    meals_per_day: int = Field(ge=2, le=5)
    diet_intensity: DietIntensity
    activity_level: ActivityLevel
    stress_level: StressLevel
    sleep_quality: SleepQuality
    muscle_percentage: float = Field(ge=0, le=100)
    water_percentage: float = Field(ge=0, le=100)
    fat_percentage: float = Field(ge=0, le=100)


class UserDetailsResponse(UserDetailsCreate):
    id: int


class UserDetailsUpdate(DateOfBirthValidationMixin, BaseModel):
    gender: Optional[Gender] = None
    height_cm: Optional[float] = Field(None, ge=50, le=300)
    weight_kg: Optional[float] = Field(None, ge=20, le=400)
    date_of_birth: Optional[date] = None
    diet_type: Optional[DietType] = None
    allergies: Optional[str] = None
    diet_goal_kg: Optional[float] = Field(None, ge=20, le=400)
    meals_per_day: Optional[int] = Field(None, ge=2, le=5)
    diet_intensity: Optional[DietIntensity] = None
    activity_level: Optional[ActivityLevel] = None
    stress_level: Optional[StressLevel] = None
    sleep_quality: Optional[SleepQuality] = None
    muscle_percentage: Optional[float] = Field(None, ge=0, le=100)
    water_percentage: Optional[float] = Field(None, ge=0, le=100)
    fat_percentage: Optional[float] = Field(None, ge=0, le=100)
