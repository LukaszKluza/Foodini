from enum import Enum
from typing import List

from pydantic import BaseModel

from backend.users.enums.language import Language


class UnitTranslation(BaseModel):
    language: Language
    translation: str


class Unit(str, Enum):
    def __new__(cls, code: str, translations: List[UnitTranslation]):
        obj = str.__new__(cls, code)
        obj._value_ = code
        obj.translations = {t.language: t for t in translations}
        return obj

    # Weight
    KILOGRAM = (
        "kg",
        [
            UnitTranslation(language=Language.EN, translation="kilogram"),
            UnitTranslation(language=Language.PL, translation="kilogram"),
        ],
    )
    GRAM = (
        "g",
        [
            UnitTranslation(language=Language.EN, translation="gram"),
            UnitTranslation(language=Language.PL, translation="gram"),
        ],
    )
    MILLIGRAM = (
        "mg",
        [
            UnitTranslation(language=Language.EN, translation="milligram"),
            UnitTranslation(language=Language.PL, translation="miligram"),
        ],
    )

    # Volume
    LITER = (
        "l",
        [
            UnitTranslation(language=Language.EN, translation="liter"),
            UnitTranslation(language=Language.PL, translation="litr"),
        ],
    )
    MILLILITER = (
        "ml",
        [
            UnitTranslation(language=Language.EN, translation="milliliter"),
            UnitTranslation(language=Language.PL, translation="mililitr"),
        ],
    )
    CUP = (
        "cup",
        [
            UnitTranslation(language=Language.EN, translation="cup"),
            UnitTranslation(language=Language.PL, translation="filiżanka"),
        ],
    )
    TABLESPOON = (
        "tbsp",
        [
            UnitTranslation(language=Language.EN, translation="tablespoon"),
            UnitTranslation(language=Language.PL, translation="łyżka"),
        ],
    )
    TEASPOON = (
        "tsp",
        [
            UnitTranslation(language=Language.EN, translation="teaspoon"),
            UnitTranslation(language=Language.PL, translation="łyżeczka"),
        ],
    )

    # Pieces
    PIECE = (
        "piece",
        [
            UnitTranslation(language=Language.EN, translation="piece"),
            UnitTranslation(language=Language.PL, translation="sztuka"),
        ],
    )
    SLICE = (
        "slice",
        [
            UnitTranslation(language=Language.EN, translation="slice"),
            UnitTranslation(language=Language.PL, translation="plaster"),
        ],
    )
    PACK = (
        "pack",
        [
            UnitTranslation(language=Language.EN, translation="pack"),
            UnitTranslation(language=Language.PL, translation="opakowanie"),
        ],
    )
    CAN = (
        "can",
        [
            UnitTranslation(language=Language.EN, translation="can"),
            UnitTranslation(language=Language.PL, translation="puszka"),
        ],
    )
    BOTTLE = (
        "bottle",
        [
            UnitTranslation(language=Language.EN, translation="bottle"),
            UnitTranslation(language=Language.PL, translation="butelka"),
        ],
    )

    # Other kitchen measures
    PINCH = (
        "pinch",
        [
            UnitTranslation(language=Language.EN, translation="pinch"),
            UnitTranslation(language=Language.PL, translation="szczypta"),
        ],
    )
    DASH = (
        "dash",
        [
            UnitTranslation(language=Language.EN, translation="dash"),
            UnitTranslation(language=Language.PL, translation="kropla"),
        ],
    )
    HANDFUL = (
        "handful",
        [
            UnitTranslation(language=Language.EN, translation="handful"),
            UnitTranslation(language=Language.PL, translation="garść"),
        ],
    )
    STICK = (
        "stick",
        [
            UnitTranslation(language=Language.EN, translation="stick"),
            UnitTranslation(language=Language.PL, translation="laska"),
        ],
    )

    def translate(self, language: Language) -> str:
        return self.translations[language].translation
