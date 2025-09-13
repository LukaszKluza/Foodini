from pydantic import model_validator

from backend.core.value_error_exception import ValueErrorException
from backend.user_details.enums import DietType


class DietGoalValidationMixin:
    @model_validator(mode="after")
    def check_diet_goal(cls, values):
        if values.diet_type == DietType.FAT_LOSS and values.diet_goal_kg >= values.weight_kg:
            raise ValueErrorException("Diet goal can't be greater than weight for diet type FAT LOSS.",)
        elif values.diet_type == DietType.MUSCLE_GAIN and values.diet_goal_kg <= values.weight_kg:
            raise ValueErrorException("Diet goal can't be lower than weight for diet type MUSCLE GAIN.")
        elif values.diet_type == DietType.WEIGHT_MAINTENANCE and values.diet_goal_kg != values.weight_kg:
            raise ValueErrorException("For diet type WEIGHT_MAINTENANCE diet goal must be equal your normal weight.")
        return values
