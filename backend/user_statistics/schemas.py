from datetime import date
from typing import List

from pydantic import BaseModel, Field


class DailyCaloriesStat(BaseModel):
    day: date
    calories: int = Field(..., ge=0)

    class Config:
        from_attributes = True


class UserStatisticsSchema(BaseModel):
    target_calories: int = Field(..., ge=0)
    weekly_calories_consumption: List[DailyCaloriesStat]

    class Config:
        from_attributes = True
