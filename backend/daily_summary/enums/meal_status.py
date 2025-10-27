from enum import Enum


class MealStatus(Enum):
    TO_EAT = "toEat"
    PENDING = "pending"
    EATEN = "eaten"
    SKIPPED = "skipped"
