from pydantic import model_validator

from backend.core.value_error_exception import ValueErrorException


class MealInfoMixin:
    @model_validator(mode="after")
    def validate_custom_or_generated(cls, values):
        meal_id = values.meal_id
        custom_name = values.custom_name

        if meal_id is None and custom_name is None:
            raise ValueErrorException("You must set either 'meal_id' or 'custom_name'.")
        return values
