import pycountry
from pydantic import field_validator

from backend.core.value_error_exception import ValueErrorException


class CountryValidationMixin:
    @field_validator("country")
    def validate_country(cls, value: str) -> str:
        try:
            country = pycountry.countries.get(name=value)
            if not country:
                raise ValueErrorException(f"Invalid country name: '{value}'.")
            return country.name
        except LookupError:
            raise ValueErrorException("Invalid country format") from None
