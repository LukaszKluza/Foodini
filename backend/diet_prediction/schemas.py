from pydantic import BaseModel
from typing import Optional, List


class MealResponse(BaseModel):
    id: int
    name: str
    calories: int
    protein: int
    fat: int
    carbs: int
    status: str


class DailySummaryResponse(BaseModel):
    id: int
    date: str
    calories_consumed: int
    protein_consumed: int
    fat_consumed: int
    carbs_consumed: int
    next_meal: Optional[int]
    meals_list: List[MealResponse]


class DailySummaryUpdateRequest(BaseModel):
    eaten_meal_id: int
