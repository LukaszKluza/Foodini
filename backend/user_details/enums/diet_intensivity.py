from enum import Enum


class DietIntensivity(str, Enum):
    SLOW = "slow"
    NORMAL = "normal"
    FAST = "fast"
