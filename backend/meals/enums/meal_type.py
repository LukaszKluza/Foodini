from enum import Enum


class MealType(str, Enum):
    BREAKFAST = "breakfast"
    MORNING_SNACK = "morning_snack"
    LUNCH = "lunch"
    AFTERNOON_SNACK = "afternoon_snack"
    DINNER = "dinner"
    EVENING_SNACK = "evening_snack"

    def __str__(self):
        return self.value

    @property
    def order(self) -> int:
        orders = {
            MealType.BREAKFAST: 0,
            MealType.MORNING_SNACK: 1,
            MealType.LUNCH: 2,
            MealType.AFTERNOON_SNACK: 3,
            MealType.DINNER: 4,
            MealType.EVENING_SNACK: 5,
        }
        return orders[self]

    @classmethod
    def sorted_meals(cls):
        return sorted(cls, key=lambda meal: meal.order)

    @classmethod
    def _missing_(cls, value):
        if isinstance(value, str):
            for member in cls:
                if member.value == value.lower():
                    return member
        return super()._missing_(value)
