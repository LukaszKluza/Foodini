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

    @staticmethod
    def from_custom_meal_request(request) -> "MealCreate":
        return MealCreate(
            meal_name=request.custom_name,
            meal_type=request.meal_type,
            calories=request.custom_calories,
            protein=request.custom_protein,
            carbs=request.custom_carbs,
            fat=request.custom_fat,
            weight=request.custom_weight,
            is_generated=False,
        )


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
