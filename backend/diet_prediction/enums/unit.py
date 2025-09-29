from enum import Enum


class Unit(str, Enum):
    # Weight
    KILOGRAM = "kg"
    GRAM = "g"
    MILLIGRAM = "mg"

    # Volume
    LITER = "l"
    MILLILITER = "ml"
    CUP = "cup"
    TABLESPOON = "tbsp"
    TEASPOON = "tsp"

    # Pieces
    PIECE = "piece"
    SLICE = "slice"
    PACK = "pack"
    CAN = "can"
    BOTTLE = "bottle"

    # Other kitchen measures
    PINCH = "pinch"
    DASH = "dash"
    HANDFUL = "handful"
    STICK = "stick"
