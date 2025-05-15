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
        return value
