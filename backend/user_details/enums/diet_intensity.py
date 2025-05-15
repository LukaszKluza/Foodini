from enum import Enum


class DietIntensity(str, Enum):
    SLOW = "slow"
    NORMAL = "normal"
    FAST = "fast"
