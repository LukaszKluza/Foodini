from enum import Enum


class DailyBudget(str, Enum):
    LOW = "low"
    MEDIUM = "medium"
    HIGH = "high"
