from datetime import date
from typing import Optional, Type

import cv2
import numpy as np
from fastapi import UploadFile

from backend.core.logger import logger
from backend.core.value_error_exception import ValueErrorException
from backend.daily_summary.schemas import CustomMealUpdateRequest
from backend.meals.enums.meal_type import MealType
from backend.models import User

A_CODE = {
    "0001101": "0",
    "0011001": "1",
    "0010011": "2",
    "0111101": "3",
    "0100011": "4",
    "0110001": "5",
    "0101111": "6",
    "0111011": "7",
    "0110111": "8",
    "0001011": "9",
}

B_CODE = {
    "0100111": "0",
    "0110011": "1",
    "0011011": "2",
    "0100001": "3",
    "0011101": "4",
    "0111001": "5",
    "0000101": "6",
    "0010001": "7",
    "0001001": "8",
    "0010111": "9",
}

C_CODE = {
    "1110010": "0",
    "1100110": "1",
    "1101100": "2",
    "1000010": "3",
    "1011100": "4",
    "1001110": "5",
    "1010000": "6",
    "1000100": "7",
    "1001000": "8",
    "1110100": "9",
}

FIRST_DIGIT_PATTERNS = {
    "AAAAAA": "0",
    "AABABB": "1",
    "AABBAB": "2",
    "AABBBA": "3",
    "ABAABB": "4",
    "ABBAAB": "5",
    "ABBBAA": "6",
    "ABABAB": "7",
    "ABABBA": "8",
    "ABBABA": "9",
}


def _decode_first_digit(left_types):
    pattern = "".join(left_types)
    return FIRST_DIGIT_PATTERNS.get(pattern)


def _validate_check_sum(barcode: str) -> bool:
    if len(barcode) != 13 or not barcode.isdigit():
        return False

    digits = [int(d) for d in barcode]
    odd_digits = digits[-3::-2]
    even_digits = digits[-2::-2]

    checksum = sum(odd_digits) + 3 * sum(even_digits)
    return (checksum + digits[-1]) % 10 == 0


def _decode_ean13_from_image(img: np.ndarray) -> str:
    _, thresh = cv2.threshold(img, 128, 255, cv2.THRESH_BINARY | cv2.THRESH_OTSU)

    row = thresh[thresh.shape[0] // 2, :]

    binary = np.where(row < 128, 1, 0)

    start = np.where(binary[: len(binary) // 2] == 1)[0][0]
    stop = np.where(binary[len(binary) // 2 :] == 1)[0][-1] + len(binary) // 2
    cols = binary[start:stop]

    module_width = len(cols) / 95
    modules = []
    for i in range(95):
        segment = cols[int(i * module_width) : int((i + 1) * module_width)]
        modules.append(1 if segment.mean() > 0.5 else 0)
    modules = np.array(modules)

    left_digits = []
    left_types = []

    for i in range(3, 45, 7):
        pattern = "".join(map(str, modules[i : i + 7]))
        if pattern in A_CODE:
            left_digits.append(A_CODE[pattern])
            left_types.append("A")
        elif pattern in B_CODE:
            left_digits.append(B_CODE[pattern])
            left_types.append("B")
        else:
            logger.debug("Decode image: invalid left side pattern")
            raise ValueErrorException("Failed to decode barcode")

    first_digit = _decode_first_digit(left_types)
    if first_digit is None:
        logger.debug("Decode image: cannot decode first EAN digit")
        raise ValueErrorException("Failed to decode barcode")

    right_digits = []
    for i in range(50, 92, 7):
        pattern = "".join(map(str, modules[i : i + 7]))
        if pattern in C_CODE:
            right_digits.append(C_CODE[pattern])
        else:
            logger.debug("Decode image: invalid right side pattern")
            raise ValueErrorException("Failed to decode barcode")

    return first_digit + "".join(left_digits) + "".join(right_digits)


class BarcodeScanningService:
    def __init__(self, open_food_facts_gateway, daily_summary_gateway):
        self.open_food_facts_gateway = open_food_facts_gateway
        self.daily_summary_gateway = daily_summary_gateway

    async def process_scan(
        self, user: Type[User], day: date, meal_type: MealType, barcode: Optional[str], image: Optional[UploadFile]
    ):
        product = None
        if barcode:
            product = await self._process_barcode(barcode)
        if image:
            product = await self._process_image(image)

        if not product:
            logger.debug("Decode image: product not found")
            raise ValueErrorException("Product not found")

        custom_meal = CustomMealUpdateRequest(
            day=day,
            meal_type=meal_type,
            custom_name=product.name,
            custom_calories=product.calories,
            custom_protein=product.protein,
            custom_carbs=product.carbs,
            custom_fat=product.fat,
            custom_weight=product.weight,
            eaten_weight=product.eaten_weight,
        )
        meal_info = await self.daily_summary_gateway.add_custom_meal(user, custom_meal)
        return meal_info

    async def _process_barcode(self, barcode: str):
        if not _validate_check_sum(barcode):
            logger.debug("Decode image: check sum failed")
            raise ValueErrorException("Invalid barcode")

        product = await self.open_food_facts_gateway.get_product_details_by_barcode(barcode)
        return product

    async def _process_image(self, image: UploadFile):
        content = await image.read()
        nparr = np.frombuffer(content, np.uint8)
        img = cv2.imdecode(nparr, cv2.IMREAD_GRAYSCALE)

        if img is None:
            logger.debug("Invalid barcode: img is None")
            raise ValueErrorException("Invalid barcode")

        barcode = _decode_ean13_from_image(img)

        if not barcode or not _validate_check_sum(barcode):
            logger.debug("Invalid barcode: barcode is None or check sum failed")
            raise ValueErrorException("Invalid barcode")

        product = await self.open_food_facts_gateway.get_product_details_by_barcode(barcode)
        return product
