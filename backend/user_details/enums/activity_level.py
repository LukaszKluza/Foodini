from enum import Enum


class ActivityLevel(str, Enum):
    VERY_LOW = "very_low"
    LIGHT = "light"
    MODERATE = "moderate"
    ACTIVE = "active"
    VERY_ACTIVE = "very_active"

    def get_pal(self):
        return {
            ActivityLevel.VERY_LOW: 1.2,
            ActivityLevel.LIGHT: 1.4,
            ActivityLevel.MODERATE: 1.6,
            ActivityLevel.ACTIVE: 1.8,
            ActivityLevel.VERY_ACTIVE: 2.0,
        }[self]