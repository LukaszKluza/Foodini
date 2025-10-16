from datetime import date
from typing import Dict, Optional

from pydantic import BaseModel, Field

from backend.diet_generation.enums.meal_status import MealStatus
from backend.diet_generation.enums.meal_type import MealType
from backend.diet_generation.mixins.meal_info_mixin import MealInfoMixin


class MealInfo(MealInfoMixin, BaseModel):
    meal_id: Optional[int] = None
    status: MealStatus = Field(default=MealStatus.TO_EAT)
    custom_name: Optional[str] = None
    custom_calories: Optional[int] = None
    custom_protein: Optional[int] = None
    custom_carbs: Optional[int] = None
    custom_fats: Optional[int] = None

    model_config = {"use_enum_values": True}


class DailyMealsCreate(BaseModel):
    day: date
    meals: Dict[MealType, MealInfo]
    target_calories: int
    target_protein: int
    target_carbs: int
    target_fats: int

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


class CustomMealUpdateRequest(BaseModel):
    day: date
    meal_type: MealType
    custom_name: str
    custom_calories: int = Field(default=0, ge=0)
    custom_protein: int = Field(default=0, ge=0)
    custom_carbs: int = Field(default=0, ge=0)
    custom_fats: int = Field(default=0, ge=0)
    status: MealStatus = Field(default=MealStatus.EATEN)
