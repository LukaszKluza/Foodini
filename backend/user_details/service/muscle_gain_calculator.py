from backend.settings import config
from backend.user_details.schemas import PredictedMacros
from backend.user_details.service.macro_calculator import MacroCalculator


class MuscleGainCalculator(MacroCalculator):
    def calculate(self):
        protein = self.weight_kg * 1.8
        fat = self.calories * 0.3 / config.FAT_CONVERSION_FACTOR
        carbs = (
            self.calories - (protein * config.PROTEIN_CONVERSION_FACTOR + fat * config.FAT_CONVERSION_FACTOR)
        ) / config.CARBS_CONVERSION_FACTOR

        return PredictedMacros(protein=int(protein), fat=int(fat), carbs=int(carbs))
