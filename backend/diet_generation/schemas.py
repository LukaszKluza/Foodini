from datetime import date
from typing import Dict, Optional
from uuid import UUID

from pydantic import BaseModel, Field

from backend.diet_generation.enums.meal_status import MealStatus
from backend.diet_generation.enums.meal_type import MealType
from backend.diet_generation.mixins.meal_info_mixin import MealInfoMixin


class MealInfo(MealInfoMixin, BaseModel):
    meal_id: Optional[UUID] = None
    status: MealStatus = Field(default=MealStatus.TO_EAT)
    custom_name: Optional[str] = None
    custom_calories: Optional[int] = None
    custom_protein: Optional[int] = None
    custom_carbs: Optional[int] = None
    custom_fat: Optional[int] = None

    model_config = {"use_enum_values": True}


class DailyMealsCreate(BaseModel):
    day: date
    meals: Dict[MealType, MealInfo]
    target_calories: int
    target_protein: int
    target_carbs: int
    target_fat: int

    model_config = {"use_enum_values": True}


class DailyMacrosSummaryCreate(BaseModel):
    day: date
    calories: int = Field(default=0, ge=0)
    protein: int = Field(default=0, ge=0)
    carbs: int = Field(default=0, ge=0)
    fat: int = Field(default=0, ge=0)


class MealInfoUpdateRequest(BaseModel):
    day: date
    meal_type: MealType
    status: MealStatus


class CustomMealUpdateRequest(BaseModel):
    day: date
    meal_type: MealType
    custom_name: Optional[str] = None
    custom_calories: Optional[int] = Field(default=None, ge=0)
    custom_protein: Optional[int] = Field(default=None, ge=0)
    custom_carbs: Optional[int] = Field(default=None, ge=0)
    custom_fat: Optional[int] = Field(default=None, ge=0)
    status: MealStatus = Field(default=MealStatus.EATEN)


class MealCreate(BaseModel):
    meal_name: str = Field(min_length=1)
    meal_type: MealType
    icon_id: int
    calories: int = Field(default=0, ge=0)
    protein: int = Field(default=0, ge=0)
    fat: int = Field(default=0, ge=0)
    carbs: int = Field(default=0, ge=0)
