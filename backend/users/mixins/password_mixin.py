import re

from pydantic import field_validator

from backend.core.value_error_exception import ValueErrorException


class PasswordValidationMixin:
    @field_validator("password")
    def validate_password(cls, value: str) -> str:
        if len(value) < 8:
            raise ValueErrorException("Password must be at least 8 characters long")
        if not re.search(r"[A-Z]", value):
            raise ValueErrorException("Password must contain at least one uppercase letter")
        if not re.search(r"[a-z]", value):
            raise ValueErrorException("Password must contain at least one lowercase letter")
        if not re.search(r"[0-9]", value):
            raise ValueErrorException("Password must contain at least one digit")
        return value
