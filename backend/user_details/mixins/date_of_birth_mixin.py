from datetime import date, datetime

from pydantic import field_validator

from backend.settings import config


class DateOfBirthValidationMixin:
    @field_validator("date_of_birth")
    def check_date_of_birth(cls, dob: date) -> date:
        today = datetime.now(config.TIMEZONE).date()
        if dob:
            if dob > today:
                raise ValueError("Date of birth cannot be in the future.")
        return dob
