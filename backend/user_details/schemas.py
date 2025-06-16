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
    gender: Gender
    height_cm: float = Field(..., ge=60, le=230)
    weight_kg: float = Field(..., ge=20, le=160)
    date_of_birth: date
    diet_type: DietType
    allergies: List[Allergies]
    diet_goal_kg: float = Field(..., ge=20, le=160)
    meals_per_day: int = Field(ge=1, le=6)
    diet_intensity: DietIntensity
    activity_level: ActivityLevel
    stress_level: StressLevel
    sleep_quality: SleepQuality
    muscle_percentage: Optional[float] = Field(default=None, ge=0, le=100)
    water_percentage: Optional[float] = Field(default=None, ge=0, le=100)
    fat_percentage: Optional[float] = Field(default=None, ge=0, le=100)


class UserDetailsUpdate(DateOfBirthValidationMixin, BaseModel):
    gender: Optional[Gender] = None
    height_cm: Optional[float] = Field(None, ge=60, le=230)
    weight_kg: Optional[float] = Field(None, ge=20, le=160)
    date_of_birth: Optional[date] = None
    diet_type: Optional[DietType] = None
    allergies: Optional[List[Allergies]] = None
    diet_goal_kg: Optional[float] = Field(None, ge=20, le=160)
    meals_per_day: Optional[int] = Field(None, ge=1, le=6)
    diet_intensity: Optional[DietIntensity] = None
    activity_level: Optional[ActivityLevel] = None
    stress_level: Optional[StressLevel] = None
    sleep_quality: Optional[SleepQuality] = None
    muscle_percentage: Optional[float] = Field(None, ge=0, le=100)
    water_percentage: Optional[float] = Field(None, ge=0, le=100)
    fat_percentage: Optional[float] = Field(None, ge=0, le=100)

    @staticmethod
    def map(data: UserDetailsCreate) -> "UserDetailsUpdate":
        return UserDetailsUpdate(
            gender=data.gender,
            height_cm=data.height_cm,
            weight_kg=data.weight_kg,
            date_of_birth=data.date_of_birth,
            diet_type=data.diet_type,
            allergies=data.allergies,
            diet_goal_kg=data.diet_goal_kg,
            meals_per_day=data.meals_per_day,
            diet_intensity=data.diet_intensity,
            activity_level=data.activity_level,
            stress_level=data.stress_level,
            sleep_quality=data.sleep_quality,
            muscle_percentage=data.muscle_percentage,
            water_percentage=data.water_percentage,
            fat_percentage=data.fat_percentage,
        )
