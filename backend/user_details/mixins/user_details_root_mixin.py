from pydantic import model_validator

from backend.user_details.enums import DietType


class DietGoalValidationMixin:
    @model_validator(mode="after")
    def check_diet_goal(cls, values):
        if values.diet_type == DietType.FAT_LOSS and values.diet_goal_kg >= values.weight_kg:
            raise ValueError("diet_goal_kg must be less than weight_kg for fat_loss.")
        if values.diet_type == DietType.MUSCLE_GAIN and values.diet_goal_kg <= values.weight_kg:
            raise ValueError("diet_goal_kg must be greater than weight_kg for muscle_gain.")
        return values
