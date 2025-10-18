from datetime import date
from typing import Dict, Optional

from pydantic import BaseModel, Field, model_validator

from backend.diet_generation.enums.meal_status import MealStatus
from backend.diet_generation.enums.meal_type import MealType
from backend.diet_generation.mixins.meal_info_mixin import MealInfoMixin


class MealInfo(MealInfoMixin, BaseModel):
    meal_id: Optional[int] = None
    status: MealStatus = Field(default=MealStatus.TO_EAT)
    custom_name: Optional[str] = None
    custom_calories: Optional[int] = None
    custom_protein: Optional[int] = None
    custom_carbs: Optional[int] = None
    custom_fats: Optional[int] = None

    model_config = {"use_enum_values": True}


class DailyMealsCreate(BaseModel):
    day: date
    meals: Dict[MealType, MealInfo]
    target_calories: int
    target_protein: int
    target_carbs: int
    target_fats: int

    model_config = {"use_enum_values": True}

    @model_validator(mode="before")
    def preprocess(cls, data):
        if isinstance(data, dict):
            predictions = data.pop("user_diet_predictions", None)
            if predictions:
                if hasattr(predictions, "model_dump"):
                    predictions = predictions.model_dump()

                data["target_calories"] = predictions.get("target_calories", 0)
                data["target_protein"] = predictions.get("protein", 0)
                data["target_carbs"] = predictions.get("carbs", 0)
                data["target_fats"] = predictions.get("fat", 0)

        return data


class DailyMacrosSummaryCreate(BaseModel):
    day: date
    calories: int = Field(default=0, ge=0)
    protein: int = Field(default=0, ge=0)
    carbs: int = Field(default=0, ge=0)
    fats: int = Field(default=0, ge=0)


class MealInfoUpdateRequest(BaseModel):
    day: date
    meal_type: MealType
    status: MealStatus


class CustomMealUpdateRequest(BaseModel):
    day: date
    meal_type: MealType
    custom_name: Optional[str] = None
    custom_calories: int = Field(default=0, ge=0)
    custom_protein: int = Field(default=0, ge=0)
    custom_carbs: int = Field(default=0, ge=0)
    custom_fats: int = Field(default=0, ge=0)
    status: MealStatus = Field(default=MealStatus.EATEN)


class MealCreate(BaseModel):
    meal_name: str = Field(min_length=1)
    meal_type: MealType
    icon_id: int
    calories: int = Field(default=0, ge=0)
    protein: int = Field(default=0, ge=0)
    fat: int = Field(default=0, ge=0)
    carbs: int = Field(default=0, ge=0)

    @model_validator(mode="before")
    def preprocess(cls, data):
        if isinstance(data, dict):
            macros = data.pop("macros", {})
            data["protein"] = int(macros.get("protein", 0))
            data["fat"] = int(macros.get("fat", 0))
            data["carbs"] = int(macros.get("carbs", 0))

            meal_type = MealType(data["meal_type"].lower())
            data["meal_type"] = meal_type
            data["icon_id"] = meal_type.order
            data["meal_name"] = data["meal_name"].capitalize()
        return data
