from enum import Enum


class DietIntensity(str, Enum):
    SLOW = "slow"
    NORMAL = "normal"
    FAST = "fast"

    def get_intensity_factor(self):
        return {
            DietIntensity.SLOW: 0.1,
            DietIntensity.NORMAL: 0.15,
            DietIntensity.FAST: 0.25,
        }[self]
