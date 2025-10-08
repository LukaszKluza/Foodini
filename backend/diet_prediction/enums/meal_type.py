from enum import Enum


class MealType(Enum):
    BREAKFAST = "breakfast"
    MORNING_SNACK = "morning_snack"
    LUNCH = "lunch"
    AFTERNOON_SNACK = "afternoon_snack"
    DINNER = "dinner"
    EVENING_SNACK = "evening_snack"

    def __str__(self):
        return self.value

    @classmethod
    def _missing_(cls, value):
        for member in cls:
            if member.value == value:
                return member
        return None
