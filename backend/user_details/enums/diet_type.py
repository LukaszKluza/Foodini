from enum import Enum


class DietType(str, Enum):
    FAT_LOSS = "fat_loss"
    MUSCLE_GAIN = "muscle_gain"
    WEIGHT_MAINTENANCE = "weight_maintenance"
    VEGETARIAN = "vegetarian"
    VEGAN = "vegan"
    KETO = "keto"
