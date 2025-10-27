from pydantic import BaseModel, Field

from backend.meals.enums.meal_type import MealType


class MealCreate(BaseModel):
    meal_name: str = Field(min_length=1)
    meal_type: MealType
    icon_id: int
    calories: int = Field(default=0, ge=0)
    protein: int = Field(default=0, ge=0)
    fat: int = Field(default=0, ge=0)
    carbs: int = Field(default=0, ge=0)
