from pydantic import field_validator
from backend.settings import config
from datetime import date


class DateOfBirthValidationMixin:
    @field_validator("date_of_birth")
    def check_date_of_birth(cls, value: str) -> str:
        dob = value.get("date_of_birth")
        today = date.now(config.TIMEZONE)
        if dob:
            if dob > today:
                raise ValueError("Date of birth cannot be in the future.")
            age = (
                today.year
                - dob.year
                - ((today.month, today.day) < (dob.month, dob.day))
            )
            if age < 5 or age > 120:
                raise ValueError("Age must be between 5 and 120.")
        return value
