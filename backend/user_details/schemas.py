from datetime import date
from typing import List, Optional

from pydantic import BaseModel, Field

from backend.models import UserDietPredictions
from backend.user_details.enums import (
    ActivityLevel,
    DietaryRestriction,
    DietIntensity,
    DietType,
    Gender,
    SleepQuality,
    StressLevel,
)
from backend.user_details.enums.diet_style import DietStyle
from backend.user_details.mixins import DateOfBirthValidationMixin, DietGoalValidationMixin
from backend.user_details.mixins.float_field_validator_mixin import FloatFieldValidatorMixin


class UserDetailsCreate(DietGoalValidationMixin, DateOfBirthValidationMixin, FloatFieldValidatorMixin, BaseModel):
    gender: Gender
    height_cm: float = Field(..., ge=60, le=230)
    weight_kg: float = Field(..., ge=20, le=160)
    date_of_birth: date
    diet_type: DietType
    diet_style: Optional[DietStyle]
    dietary_restrictions: List[DietaryRestriction]
    diet_goal_kg: float = Field(..., ge=20, le=160)
    meals_per_day: int = Field(ge=1, le=6)
    diet_intensity: DietIntensity
    activity_level: ActivityLevel
    stress_level: StressLevel
    sleep_quality: SleepQuality
    muscle_percentage: Optional[float] = Field(default=None, ge=0, le=100)
    water_percentage: Optional[float] = Field(default=None, ge=0, le=100)
    fat_percentage: Optional[float] = Field(default=None, ge=0, le=100)


class UserDetailsUpdate(DietGoalValidationMixin, DateOfBirthValidationMixin, FloatFieldValidatorMixin, BaseModel):
    gender: Optional[Gender] = None
    height_cm: Optional[float] = Field(None, ge=60, le=230)
    weight_kg: Optional[float] = Field(None, ge=20, le=160)
    date_of_birth: Optional[date] = None
    diet_type: Optional[DietType] = None
    diet_style: Optional[DietStyle] = None
    dietary_restrictions: Optional[List[DietaryRestriction]] = None
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
            diet_style=data.diet_style,
            dietary_restrictions=data.dietary_restrictions,
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


class PredictedMacros(BaseModel):
    protein: float
    fat: float
    carbs: float


class PredictedCalories(BaseModel):
    bmr: int
    tdee: int
    target_calories: int
    diet_duration_days: Optional[int] = None
    predicted_macros: PredictedMacros

    @staticmethod
    def from_user_diet_predictions(user_diet_predictions: UserDietPredictions):
        return PredictedCalories(
            bmr=user_diet_predictions.bmr,
            tdee=user_diet_predictions.tdee,
            target_calories=user_diet_predictions.target_calories,
            diet_duration_days=user_diet_predictions.diet_duration_days,
            predicted_macros=PredictedMacros(
                protein=user_diet_predictions.protein, fat=user_diet_predictions.fat, carbs=user_diet_predictions.carbs
            ),
        )
