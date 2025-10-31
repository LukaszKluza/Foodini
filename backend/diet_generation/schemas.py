from datetime import date
from typing import Dict, List, Optional
from uuid import UUID
from typing import Any, Dict, List, Optional

from pydantic import BaseModel, Field

from backend.diet_generation.enums.meal_status import MealStatus
from backend.diet_generation.enums.meal_type import MealType
from backend.diet_generation.mixins.meal_info_mixin import MealInfoMixin
from backend.models import Ingredients, Step
from backend.users.enums.language import Language

from backend.user_details.enums import DietaryRestriction

class MealInfo(MealInfoMixin, BaseModel):
    meal_id: Optional[UUID] = None
    status: MealStatus = Field(default=MealStatus.TO_EAT)
    custom_name: Optional[str] = None
    custom_calories: Optional[int] = None
    custom_protein: Optional[float] = None
    custom_carbs: Optional[float] = None
    custom_fat: Optional[float] = None

class IngredientCreate(BaseModel):
    volume: float = Field(default=0, ge=0)
    unit: str = Field(default="")
    name: str = Field(min_length=1)
    optional_note: Optional[str] = None


class StepCreate(BaseModel):
    description: str = Field(min_length=1)
    optional: bool = Field(default=False)
class DailyMealsCreate(BaseModel):
    day: date
    meals: Dict[MealType, MealInfo]
    target_calories: int
    target_protein: float
    target_carbs: float
    target_fat: float


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

class MealInfoUpdateRequest(BaseModel):
    day: date
    meal_id: UUID
    status: MealStatus

class DietGenerationOutput(BaseModel):
    meals: List[CompleteMeal]

class CustomMealUpdateRequest(BaseModel):
    day: date
    meal_type: MealType
    custom_name: Optional[str] = None
    custom_calories: Optional[int] = Field(default=None, ge=0)
    custom_protein: Optional[float] = Field(default=None, ge=0)
    custom_carbs: Optional[float] = Field(default=None, ge=0)
    custom_fat: Optional[float] = Field(default=None, ge=0)
    status: MealStatus = Field(default=MealStatus.EATEN)

class DietGenerationInput(BaseModel):
    dietary_restriction: List[DietaryRestriction]
    meals_per_day: int = Field(default=1, ge=1)
    meal_types: List[str] = Field(min_length=1)

class MealCreate(BaseModel):
    meal_type: MealType
    icon_id: UUID
    calories: int = Field(default=0, ge=0)
    protein: int = Field(default=0, ge=0)
    fat: int = Field(default=0, ge=0)
    carbs: int = Field(default=0, ge=0)
    previous_meals: Optional[List[str]] = Field(None, description="Optional list of previously generated meals.")


class MealRecipeTranslation(BaseModel):
    meal_name: str = Field(min_length=1)
    meal_description: str = Field(min_length=1)
    ingredients_list: List[IngredientCreate]
    steps: List[StepCreate]


class AgentState(BaseModel):
    targets: DietGenerationInput
    current_plan: Optional[List[CompleteMeal]] = None
    validation_report: Optional[str] = None
    correction_count: int = 0


def agent_state_to_dict(state: AgentState) -> Dict[str, Any]:
    return state.model_dump()


def create_agent_state(targets: DietGenerationInput) -> AgentState:
    return AgentState(targets=targets).model_dump()
    protein: float = Field(default=0, ge=0)
    fat: float = Field(default=0, ge=0)
    carbs: float = Field(default=0, ge=0)


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
