from typing import List, Optional
from uuid import UUID

from pydantic import BaseModel, Field

from backend.meals.enums.meal_type import MealType
from backend.models import Ingredients, Step
from backend.users.enums.language import Language


class MealCreate(BaseModel):
    meal_name: str
    meal_type: MealType
    icon_id: Optional[UUID] = None
    calories: int = Field(default=0, ge=0)
    protein: float = Field(default=0, ge=0)
    fat: float = Field(default=0, ge=0)
    carbs: float = Field(default=0, ge=0)
    weight: int = Field(default=0, ge=0, le=1250)
    is_generated: bool = Field(default=True)


class MealRecipeResponse(BaseModel):
    id: UUID
    meal_id: UUID
    language: Language
    meal_name: str
    meal_description: str
    meal_explanation: str
    ingredients: Ingredients
    steps: List[Step]
    meal_type: MealType
    icon_path: str
