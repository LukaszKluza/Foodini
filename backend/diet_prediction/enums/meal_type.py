from enum import Enum


class MealType(Enum):
    BREAKFAST = ("breakfast", 1)
    MORNING_SNACK = ("morning_snack", 2)
    LUNCH = ("lunch", 3)
    AFTERNOON_SNACK = ("afternoon_snack", 4)
    DINNER = ("dinner", 5)
    EVENING_SNACK = ("evening_snack", 6)

    def __init__(self, value, order):
        self.__value = value
        self.__order = order
