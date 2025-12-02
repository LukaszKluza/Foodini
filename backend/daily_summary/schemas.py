from datetime import date
from typing import Dict, List, Optional
from uuid import UUID

from pydantic import BaseModel, Field

from backend.daily_summary.enums.meal_status import MealStatus
from backend.meals.enums.meal_type import MealType


# TODO Review and refine the schemas, rename meal to mealItem
class BasicMealInfo(BaseModel):
    meal_id: UUID
    status: MealStatus = Field(default=MealStatus.TO_EAT)
    calories: int
    protein: float
    carbs: float
    fat: float
    weight: int


class MealInfo(BasicMealInfo):
    name: str
    description: Optional[str] = None
    explanation: Optional[str] = None


class MealInfoWithIconPath(MealInfo):
    icon_path: Optional[str] = None


class Meal(BaseModel):
    meal_items: List[MealInfoWithIconPath]
    status: MealStatus = Field(default=MealStatus.TO_EAT)


class DailyMealsCreate(BaseModel):
    day: date
    meals: Dict[MealType, List[BasicMealInfo]]
    target_calories: int
    target_protein: float
    target_carbs: float
    target_fat: float


class DailySummary(DailyMealsCreate):
    meals: Dict[MealType, Meal]
    eaten_calories: int
    eaten_protein: float
    eaten_carbs: float
    eaten_fat: float
    is_out_dated: bool
    generated_meals: Dict[MealType, MealInfoWithIconPath]


class DailyMacrosSummaryCreate(BaseModel):
    day: date
    calories: int = Field(default=0)
    protein: float = Field(default=0)
    carbs: float = Field(default=0)
    fat: float = Field(default=0)


class MealInfoUpdateRequest(BaseModel):
    day: date
    meal_type: MealType
    status: MealStatus


class CustomMealUpdateRequest(BaseModel):
    day: date
    meal_type: MealType
    meal_id: Optional[UUID] = None
    custom_name: Optional[str] = None
    custom_calories: Optional[int] = Field(default=None, ge=0)
    custom_protein: Optional[float] = Field(default=None, ge=0)
    custom_carbs: Optional[float] = Field(default=None, ge=0)
    custom_fat: Optional[float] = Field(default=None, ge=0)
    custom_weight: Optional[int] = Field(default=None, ge=0, le=1250)
    eaten_weight: Optional[int] = Field(default=None, ge=0, le=1250)


class RemoveMealRequest(BaseModel):
    day: date
    meal_type: MealType
    meal_id: UUID


class RemoveMealResponse(RemoveMealRequest):
    success: bool
