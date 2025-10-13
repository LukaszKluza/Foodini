from enum import Enum


class MealType(Enum):
    BREAKFAST = ("breakfast", 1)
    MORNING_SNACK = ("morning_snack", 2)
    LUNCH = ("lunch", 3)
    AFTERNOON_SNACK = ("afternoon_snack", 4)
    DINNER = ("dinner", 5)
    EVENING_SNACK = ("evening_snack", 6)

    @property
    def str_value(self) -> str:
        return self.value[0]

    @property
    def meal_order(self) -> int:
        return self.value[1]

    @classmethod
    def _missing_(cls, value):
        if isinstance(value, str):
            for member in cls:
                if member.str_value == value.lower():
                    return member
        return super()._missing_(value)

    def __str__(self) -> str:
        return self.str_value
