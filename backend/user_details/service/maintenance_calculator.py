from backend.user_details.schemas import PredictedMacros
from backend.user_details.service.macro_calculator import MacroCalculator


class MaintenanceCalculator(MacroCalculator):
    def calculate(self):
        protein = self.weight_kg * 2.0
        fat = self.calories * 0.25 / 9
        carbs = (self.calories - (protein * 4 + fat * 9)) / 4

        return PredictedMacros(protein=int(protein), fat=int(fat), carbs=int(carbs))
