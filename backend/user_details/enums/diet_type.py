from enum import Enum


class DietType(str, Enum):
    FAT_LOSS = "fat_loss"
    MUSCLE_GAIN = "muscle_gain"
    WEIGHT_MAINTENANCE = "weight_maintenance"

    def get_diet_type_factor(self):
        return {
            DietType.FAT_LOSS: -1,
            DietType.MUSCLE_GAIN: 1,
            DietType.WEIGHT_MAINTENANCE: 0,
        }[self]
