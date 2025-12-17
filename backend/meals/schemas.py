from typing import List, Optional
from uuid import UUID

from pydantic import BaseModel, Field

from backend.daily_summary.schemas import ComposedMealUpdateRequest
from backend.diet_generation.schemas import CompleteMeal
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
    def from_custom_meal_request(request: ComposedMealUpdateRequest) -> "MealCreate":
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

    @staticmethod
    def from_complete_meal(complete_meal: CompleteMeal, icon_id: UUID) -> "MealCreate":
        return MealCreate(
            meal_name=complete_meal.meal_name,
            meal_type=MealType(complete_meal.meal_type),
            icon_id=icon_id,
            calories=complete_meal.calories,
            protein=complete_meal.protein,
            carbs=complete_meal.carbs,
            fat=complete_meal.fat,
            weight=complete_meal.weight,
            is_generated=True,
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
