from enum import Enum


class StressLevel(str, Enum):
    LOW = "low"
    MEDIUM = "medium"
    HIGH = "high"
    EXTREME = "extreme"

    def get_stress_factor(self):
        return {
            StressLevel.LOW: 0.0,
            StressLevel.MEDIUM: 0.03,
            StressLevel.HIGH: 0.07,
            StressLevel.EXTREME: 0.10,
        }[self]
