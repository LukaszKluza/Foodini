from enum import Enum


class SleepQuality(str, Enum):
    POOR = "poor"
    FAIR = "fair"
    GOOD = "good"
    EXCELLENT = "excellent"

    def get_sleep_quality_factor(self):
        return {
            SleepQuality.POOR: -0.03,
            SleepQuality.FAIR: 0.0,
            SleepQuality.GOOD: 0.02,
            SleepQuality.EXCELLENT: 0.03,
        }[self]
