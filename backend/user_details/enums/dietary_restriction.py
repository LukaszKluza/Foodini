from enum import Enum


class DietaryRestriction(str, Enum):
    GLUTEN = "gluten"
    PEANUTS = "peanuts"
    LACTOSE = "lactose"
    FISH = "fish"
    SOY = "soy"
    WHEAT = "wheat"
    CELERY = "celery"
    SULPHITES = "sulphites"
    LUPIN = "lupin"
    VEGETARIAN = "vegetarian"
    VEGAN = "vegan"
    KETO = "keto"
