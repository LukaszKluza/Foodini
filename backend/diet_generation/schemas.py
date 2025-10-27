from typing import Dict, Optional, List, Any

from pydantic import BaseModel, Field

from backend.meals.enums.meal_type import MealType
from backend.user_details.enums import Allergies


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
    protein: int = Field(default=0, ge=0)
    fat: int = Field(default=0, ge=0)
    carbs: int = Field(default=0, ge=0)

    ingredients_list: List[IngredientCreate]
    steps: List[StepCreate]


class Output(BaseModel):
    meals: List[CompleteMeal]


class Input(BaseModel):
    allergens: List[Allergies]
    meals_per_day: int = Field(default=1, ge=1)
    calories: int = Field(default=0, ge=0)
    protein: int = Field(default=0, ge=0)
    fat: int = Field(default=0, ge=0)
    carbs: int = Field(default=0, ge=0)
    meal_types: List[str] = Field(default_factory=lambda: [m.value for m in MealType])
    previous_meals: Optional[List[str]] = Field(None, description="Optional list of previously generated meals.")


class AgentState(BaseModel):
    targets: Input
    current_plan: Optional[List[CompleteMeal]] = None
    validation_report: Optional[str] = None
    correction_count: int = 0

def agent_state_to_dict(state: AgentState) -> Dict[str, Any]:
    return state.model_dump()

def create_agent_state(targets: Input) -> AgentState:
    return AgentState(targets=targets).model_dump()