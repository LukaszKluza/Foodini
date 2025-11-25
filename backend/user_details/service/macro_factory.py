from backend.core.logger import logger
from backend.core.value_error_exception import ValueErrorException
from backend.user_details.enums import DietType
from backend.user_details.service.fat_loss_calculator import FatLossCalculator
from backend.user_details.service.maintenance_calculator import MaintenanceCalculator
from backend.user_details.service.muscle_gain_calculator import MuscleGainCalculator


class MacroFactory:
    @staticmethod
    def get_calculator(diet_type, weight_kg, calories):
        if diet_type == DietType.WEIGHT_MAINTENANCE:
            return MaintenanceCalculator(weight_kg, calories)
        elif diet_type == DietType.MUSCLE_GAIN:
            return MuscleGainCalculator(weight_kg, calories)
        elif diet_type == DietType.FAT_LOSS:
            return FatLossCalculator(weight_kg, calories)
        else:
            logger.error(f"Invalid dietType: {diet_type}")
            logger.error(f"Invalid dietType: {diet_type}")
            raise ValueErrorException("Invalid diet_type")
