from pydantic import model_validator

from backend.core.value_error_exception import ValueErrorException


class AdvancedParametersMixin:
    @model_validator(mode="after")
    def check_advanced_parameters(cls, values):
        muscle = values.muscle_percentage or 0
        water = values.water_percentage or 0
        fat = values.fat_percentage or 0

        total = fat + muscle + water
        if total > 100:
            raise ValueErrorException("Sum of advanced parameters can't be greater than 100%.")
        return values
