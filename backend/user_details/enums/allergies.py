from enum import Enum


class Allergies(str, Enum):
    GLUTEN = "gluten"
    PEANUTS = "peanuts"
    LACTOSE = "lactose"
    FISH = "fish"
    SOY = "soy"
    WHEAT = "wheat"
    CELERY = "celery"
    SULPHIDES = "sulphides"
    LUPIN = "lupin"
