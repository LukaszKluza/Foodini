from typing import List
from uuid import UUID

from pydantic import BaseModel, Field

from backend.meals.enums.meal_type import MealType
from backend.models import Ingredients, Step
from backend.users.enums.language import Language


class MealCreate(BaseModel):
    meal_type: MealType
    icon_id: UUID
    calories: int = Field(default=0, ge=0)
    protein: int = Field(default=0, ge=0)
    fat: int = Field(default=0, ge=0)
    carbs: int = Field(default=0, ge=0)


class MealRecipeResponse(BaseModel):
    id: UUID
    meal_id: UUID
    language: Language
    meal_name: str
    meal_description: str
    ingredients: Ingredients
    steps: List[Step]
    meal_type: MealType
    icon_path: str
