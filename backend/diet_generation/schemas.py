from datetime import date
from typing import Dict, List, Optional
from uuid import UUID

from pydantic import BaseModel, Field

from backend.diet_generation.enums.meal_status import MealStatus
from backend.diet_generation.enums.meal_type import MealType
from backend.diet_generation.mixins.meal_info_mixin import MealInfoMixin
from backend.models import Ingredients, Step
from backend.users.enums.language import Language


class MealInfo(MealInfoMixin, BaseModel):
    meal_id: Optional[UUID] = None
    status: MealStatus = Field(default=MealStatus.TO_EAT)
    custom_name: Optional[str] = None
    custom_calories: Optional[int] = None
    custom_protein: Optional[float] = None
    custom_carbs: Optional[float] = None
    custom_fat: Optional[float] = None

    model_config = {"use_enum_values": True}


class DailyMealsCreate(BaseModel):
    day: date
    meals: Dict[MealType, MealInfo]
    target_calories: int
    target_protein: float
    target_carbs: float
    target_fat: float

    model_config = {"use_enum_values": True}


class DailyMacrosSummaryCreate(BaseModel):
    day: date
    calories: int = Field(default=0, ge=0)
    protein: int = Field(default=0, ge=0)
    carbs: int = Field(default=0, ge=0)
    fat: int = Field(default=0, ge=0)


class MealInfoUpdateRequest(BaseModel):
    day: date
    meal_id: UUID
    status: MealStatus


class CustomMealUpdateRequest(BaseModel):
    day: date
    meal_type: MealType
    custom_name: Optional[str] = None
    custom_calories: Optional[int] = Field(default=None, ge=0)
    custom_protein: Optional[float] = Field(default=None, ge=0)
    custom_carbs: Optional[float] = Field(default=None, ge=0)
    custom_fat: Optional[float] = Field(default=None, ge=0)
    status: MealStatus = Field(default=MealStatus.EATEN)


class MealCreate(BaseModel):
    meal_type: MealType
    icon_id: UUID
    calories: int = Field(default=0, ge=0)
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
