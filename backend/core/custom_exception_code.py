from enum import Enum


class CustomExceptionCode(str, Enum):
    MISSING_DIET_PREDICTIONS = "MISSING_DIET_PREDICTIONS"
