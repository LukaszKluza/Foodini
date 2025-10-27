from pydantic import field_validator


class FloatFieldValidatorMixin:
    @field_validator(
        "height_cm",
        "weight_kg",
        "diet_goal_kg",
        "muscle_percentage",
        "water_percentage",
        "fat_percentage",
        mode="before",
    )
    def round_to_two_decimals(cls, v):
        if v is not None:
            return round(v, 2)
        return v
