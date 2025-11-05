from datetime import date
from typing import Dict, Optional
from uuid import UUID

from pydantic import BaseModel, Field

from backend.daily_summary.enums.meal_status import MealStatus
from backend.meals.enums.meal_type import MealType


class BasicMealInfo(BaseModel):
    meal_id: UUID
    status: MealStatus = Field(default=MealStatus.TO_EAT)
    calories: int
    protein: float
    carbs: float
    fat: float


class MealInfo(BasicMealInfo):
    name: str
    description: str


class MealInfoWithIconPath(MealInfo):
    icon_path: str


class DailyMealsCreate(BaseModel):
    day: date
    meals: Dict[MealType, BasicMealInfo]
    target_calories: int
    target_protein: float
    target_carbs: float
    target_fat: float


class DailySummary(DailyMealsCreate):
    meals: Dict[MealType, MealInfoWithIconPath]
    eaten_calories: int
    eaten_protein: float
    eaten_carbs: float
    eaten_fat: float


class DailyMacrosSummaryCreate(BaseModel):
    day: date
    calories: int = Field(default=0)
    protein: float = Field(default=0)
    carbs: float = Field(default=0)
    fat: float = Field(default=0)


class MealInfoUpdateRequest(BaseModel):
    day: date
    meal_id: UUID
    status: MealStatus


class CustomMealUpdateRequest(BaseModel):
    day: date
    meal_id: UUID
    custom_name: Optional[str] = None
    custom_calories: Optional[int] = Field(default=None, ge=0)
    custom_protein: Optional[float] = Field(default=None, ge=0)
    custom_carbs: Optional[float] = Field(default=None, ge=0)
    custom_fat: Optional[float] = Field(default=None, ge=0)
    status: MealStatus = Field(default=MealStatus.EATEN)
