from typing import Any, Dict, List, Optional

from pydantic import BaseModel, Field

from backend.user_details.enums import CookingSkills, DailyBudget, DietaryRestriction
from backend.user_details.enums.diet_style import DietStyle


class IngredientCreate(BaseModel):
    volume: float = Field(default=0, ge=0)
    unit: str = Field(default="")
    name: str = Field(min_length=1)
    optional_note: Optional[str] = None


class StepCreate(BaseModel):
    description: str = Field(min_length=1)
    optional: bool = Field(default=False)


class CompleteMeal(BaseModel):
    meal_name: str = Field(min_length=1)
    meal_type: str = Field(min_length=1)
    meal_description: str = Field(min_length=1)
    calories: int = Field(default=0, ge=0)
    protein: float = Field(default=0, ge=0)
    carbs: float = Field(default=0, ge=0)
    fat: float = Field(default=0, ge=0)
    weight: int = Field(default=0, ge=0)

    ingredients_list: List[IngredientCreate]
    steps: List[StepCreate]
    explanation: Optional[str] = None


class DietGenerationOutput(BaseModel):
    meals: List[CompleteMeal]


class DietGenerationInput(BaseModel):
    dietary_restriction: List[DietaryRestriction]
    meals_per_day: int = Field(default=1, ge=1)
    meal_types: List[str] = Field(min_length=1)
    calories: int = Field(default=0, ge=0)
    protein: float = Field(default=0, ge=0)
    carbs: float = Field(default=0, ge=0)
    fat: float = Field(default=0, ge=0)
    previous_meals: List[str] = ([],)
    diet_style: Optional[DietStyle] = None
    daily_budget: Optional[DailyBudget] = None
    cooking_skills: Optional[CookingSkills] = None


class MealRecipeTranslation(BaseModel):
    meal_name: str = Field(min_length=1)
    meal_description: str = Field(min_length=1)
    ingredients_list: List[IngredientCreate]
    steps: List[StepCreate]
    explanation: Optional[str] = None


class AgentState(BaseModel):
    targets: DietGenerationInput
    current_plan: Optional[List[CompleteMeal]] = None
    validation_report: Optional[str] = None
    correction_count: int = 0


def agent_state_to_dict(state: AgentState) -> Dict[str, Any]:
    return state.model_dump()


def create_agent_state(targets: DietGenerationInput) -> AgentState:
    return AgentState(targets=targets).model_dump()
