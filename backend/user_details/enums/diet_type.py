from enum import Enum


class DietType(str, Enum):
    FAT_LOSS = "fat_loss"
    MUSCLE_GAIN = "muscle_gain"
    WEIGHT_MAINTENANCE = "weight_maintenance"
    VEGETARIAN = "vegetarian"
    VEGAN = "vegan"
    KETO = "keto"

    def get_diet_type_factor(self):
        return {
            DietType.FAT_LOSS: -1,
            DietType.MUSCLE_GAIN: 1,
            DietType.WEIGHT_MAINTENANCE: 0,
            DietType.VEGETARIAN: 0,
            DietType.VEGAN: 0,
            DietType.KETO: 0,
        }[self]
