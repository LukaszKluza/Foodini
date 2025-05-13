from datetime import date
from pydantic import BaseModel, Field
from typing import Optional
from enums.gender import Gender
from enums.diet_type import DietType
from enums.diet_intensivity import DietIntensivity
from enums.activity_level import ActivityLevel
from enums.sleep_quality import SleepQuality
from enums.stress_level import StressLevel


class UserBasicInfo(BaseModel):
    gender: Gender
    height_cm: float = Field(gt=0)
    weight_kg: float = Field(gt=0)
    date_of_birth: date


class HealthMetrics(BaseModel):
    activity_level: ActivityLevel
    stress_level: StressLevel
    sleep_quality: SleepQuality
    muscle_percentage: Optional[float] = Field(None, ge=0, le=100)
    water_percentage: Optional[float] = Field(None, ge=0, le=100)
    fat_percentage: Optional[float] = Field(None, ge=0, le=100)


class DietPreferences(BaseModel):
    diet_type: DietType
    allergies: str = Field("", max_length=50)
    diet_goal_kg: float
    meals_per_day: int = Field(ge=2, le=5)
    diet_intensivity: DietIntensivity


class UserDetailsForm(BaseModel):
    basic_info: UserBasicInfo
    health: HealthMetrics
    diet: DietPreferences


class UserDetailsResponse(UserDetailsForm):
    id: int
    user_id: int


class UserDetailsUpdate(BaseModel):
    basic_info: Optional[UserBasicInfo] = None
    health: Optional[HealthMetrics] = None
    diet: Optional[DietPreferences] = None
