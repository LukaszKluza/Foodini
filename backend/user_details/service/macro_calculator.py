from abc import ABC, abstractmethod

from backend.user_details.schemas import PredictedMacros


class MacroCalculator(ABC):
    def __init__(self, weight_kg, calories):
        self.weight_kg = weight_kg
        self.calories = calories

    @abstractmethod
    def calculate(self) -> PredictedMacros:
        pass
