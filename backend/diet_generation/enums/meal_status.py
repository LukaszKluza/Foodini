from enum import Enum


class MealStatus(str, Enum):
    TO_EAT = "to_eat"
    PENDING = "pending"
    EATEN = "eaten"
    SKIPPED = "skipped"
