from datetime import date
from typing import List, Optional

from pydantic import BaseModel, Field

from backend.diet_prediction.enums.meal_status import MealStatus


class MealResponse(BaseModel):
    id: int
    name: str
    calories: int
    protein: int
    fat: int
    carbs: int
    status: str


class UserDailyMealItemCreate(BaseModel):
    meal_id: int
    status: MealStatus = MealStatus.PENDING


class UserDailySummaryCreate(BaseModel):
    day: date
    meal_items: List[UserDailyMealItemCreate]
    next_meal: Optional[int] = None
    calories_consumed: int = Field(default=0, ge=0)
    protein_consumed: int = Field(default=0, ge=0)
    fat_consumed: int = Field(default=0, ge=0)
    carbs_consumed: int = Field(default=0, ge=0)


class DailySummaryResponse(BaseModel):
    id: int
    day: date
    calories_consumed: int
    protein_consumed: int
    fat_consumed: int
    carbs_consumed: int
    next_meal: Optional[int]
    meal_items: List[MealResponse]


class DailySummaryUpdateRequest(BaseModel):
    eaten_meal_id: int
