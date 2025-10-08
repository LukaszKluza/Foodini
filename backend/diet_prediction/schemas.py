from datetime import date
from typing import Dict

from pydantic import BaseModel, Field

from backend.diet_prediction.enums.meal_status import MealStatus
from backend.diet_prediction.enums.meal_type import MealType


class MealInfo(BaseModel):
    meal_id: int
    status: MealStatus = Field(default=MealStatus.PENDING)

    model_config = {"use_enum_values": True}


class DailyMealsCreate(BaseModel):
    day: date
    meals: Dict[MealType, MealInfo]

    model_config = {"use_enum_values": True}


class DailyMacrosSummaryCreate(BaseModel):
    day: date
    calories: int = Field(default=0, ge=0)
    protein: int = Field(default=0, ge=0)
    carbs: int = Field(default=0, ge=0)
    fats: int = Field(default=0, ge=0)


class MealInfoUpdateRequest(BaseModel):
    day: date
    meal_type: MealType
    status: MealStatus
