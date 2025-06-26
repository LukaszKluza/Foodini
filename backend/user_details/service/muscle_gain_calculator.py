from backend.user_details.schemas import PredictedMacros
from backend.user_details.service.macro_calculator import MacroCalculator


class MuscleGainCalculator(MacroCalculator):
    def calculate(self):
        protein = self.weight_kg * 1.8
        fat = self.calories * 0.3 / 9
        carbs = (self.calories - (protein * 4 + fat * 9)) / 4

        return PredictedMacros(protein=int(protein), fat=int(fat), carbs=int(carbs))
