from datetime import date
from typing import Dict, List, Optional
from uuid import UUID

from pydantic import BaseModel, Field

from backend.daily_summary.enums.meal_status import MealStatus
from backend.meals.enums.meal_type import MealType
from backend.models import ComposedMealItem


# TODO Review and refine the schemas, rename meal to mealItem
class BasicMealInfo(BaseModel):
    meal_id: UUID
    status: MealStatus = Field(default=MealStatus.TO_EAT)
    calories: int
    protein: float
    carbs: float
    fat: float
    unit_weight: int
    planned_calories: int
    planned_protein: float
    planned_carbs: float
    planned_fat: float
    planned_weight: int


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


class DailySummaryDTO(DailyMealsCreate):
    meals: Dict[MealType, Meal]
    eaten_calories: int
    eaten_protein: float
    eaten_carbs: float
    eaten_fat: float
    is_out_dated: bool
    generated_meals: Dict[MealType, MealInfoWithIconPath]


class Macros(BaseModel):
    calories: int = Field(default=0)
    protein: float = Field(default=0)
    carbs: float = Field(default=0)
    fat: float = Field(default=0)


class DailyMacrosSummaryCreate(Macros):
    day: date


class MealMacros(Macros):
    day: date
    meal_id: UUID


class MealInfoUpdateRequest(BaseModel):
    day: date
    meal_type: MealType
    status: MealStatus


class ComposedMealUpdateRequest(BaseModel):
    day: date
    meal_type: MealType
    meal_id: Optional[UUID] = None
    custom_name: Optional[str] = None
    custom_calories: Optional[int] = Field(default=None, ge=0)
    custom_protein: Optional[float] = Field(default=None, ge=0)
    custom_carbs: Optional[float] = Field(default=None, ge=0)
    custom_fat: Optional[float] = Field(default=None, ge=0)
    custom_weight: Optional[int] = Field(default=None, ge=0, le=2250)
    eaten_weight: Optional[int] = Field(default=None, ge=0, le=2250)


class RemoveMealRequest(BaseModel):
    day: date
    meal_type: MealType
    meal_id: UUID


class RemoveMealResponse(RemoveMealRequest):
    success: bool


# -------------------------------------------------------------------


class MealTypeDailySummaryBase(BaseModel):
    meal_daily_summary_id: UUID
    status: MealStatus
    meal_type: MealType


class MealTypeDailySummaryWithItems(MealTypeDailySummaryBase):
    composed_meal_items: List[ComposedMealItem]


class DailySummary(BaseModel):
    daily_summary_id: UUID
    user_id: UUID
    day: date
    target_calories: int
    target_protein: float
    target_carbs: float
    target_fat: float


class DailyMealTypeSummary(DailySummary):
    meal_type_daily_summary: MealTypeDailySummaryBase


class DailyMealTypesSummaryWithItems(DailySummary):
    map_meal_type_daily_summaries: dict[MealType, MealTypeDailySummaryWithItems]


class ComposedMealItemUpdateEntity(BaseModel):
    planned_calories: int
    planned_protein: float
    planned_fat: float
    planned_carbs: float
    planned_weight: int
