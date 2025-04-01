from pydantic import field_validator
from typing import List
import pycountry


class CountryValidationMixin:
    @classmethod
    def get_available_countries(cls) -> List[str]:
        return [country.name for country in pycountry.countries]

    @field_validator("country")
    def validate_country(cls, value: str) -> str:
        try:
            country = pycountry.countries.get(name=value)
            if not country:
                available = cls.get_available_countries()[:3]
                raise ValueError(
                    f"Invalid country name: '{value}'. "
                    f"Available examples: {', '.join(available)}..."
                )
            return country.name
        except LookupError:
            raise ValueError("Invalid country format") from None
