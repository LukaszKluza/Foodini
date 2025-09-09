from pydantic import model_validator

from backend.user_details.enums import DietType


class DietGoalValidationMixin:
    @model_validator(mode="after")
    def check_diet_goal(cls, values):
        if values.diet_type == DietType.FAT_LOSS and values.diet_goal_kg >= values.weight_kg:
            raise ValueError("diet_goal_kg must be less than weight_kg for fat_loss.")
        elif values.diet_type == DietType.MUSCLE_GAIN and values.diet_goal_kg <= values.weight_kg:
            raise ValueError("diet_goal_kg must be greater than weight_kg for muscle_gain.")
        elif values.diet_type == DietType.WEIGHT_MAINTENANCE and values.diet_goal_kg != values.weight_kg:
            raise ValueError("For WEIGHT_MAINTENANCE diet_goal_kg must be equal your normal weight .")
        return values
