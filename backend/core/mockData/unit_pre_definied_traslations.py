from backend.diet_prediction.enums.unit import Unit
from backend.users.enums.language import Language

UNIT_TRANSLATIONS = {
    Unit.KILOGRAM: {
        Language.EN: "kg",
        Language.PL: "kilogram",
    },
    Unit.GRAM: {
        Language.EN: "g",
        Language.PL: "gram",
    },
    Unit.MILLIGRAM: {
        Language.EN: "mg",
        Language.PL: "miligram",
    },
    Unit.LITER: {
        Language.EN: "l",
        Language.PL: "litr",
    },
    Unit.MILLILITER: {
        Language.EN: "ml",
        Language.PL: "mililitr",
    },
    Unit.CUP: {
        Language.EN: "cup",
        Language.PL: "szklanka",
    },
    Unit.TABLESPOON: {
        Language.EN: "tbsp",
        Language.PL: "łyżka",
    },
    Unit.TEASPOON: {
        Language.EN: "tsp",
        Language.PL: "łyżeczka",
    },
    Unit.PIECE: {
        Language.EN: "piece",
        Language.PL: "sztuka",
    },
    Unit.SLICE: {
        Language.EN: "slice",
        Language.PL: "plaster",
    },
    Unit.PACK: {
        Language.EN: "pack",
        Language.PL: "opakowanie",
    },
    Unit.CAN: {
        Language.EN: "can",
        Language.PL: "puszka",
    },
    Unit.BOTTLE: {
        Language.EN: "bottle",
        Language.PL: "butelka",
    },
    Unit.PINCH: {
        Language.EN: "pinch",
        Language.PL: "szczypta",
    },
    Unit.DASH: {
        Language.EN: "dash",
        Language.PL: "odrobina",
    },
    Unit.HANDFUL: {
        Language.EN: "handful",
        Language.PL: "garść",
    },
    Unit.STICK: {
        Language.EN: "stick",
        Language.PL: "kostka / patyczek",
    },
}
