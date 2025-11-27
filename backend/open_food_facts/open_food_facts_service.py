import openfoodfacts

from backend.core.not_found_in_database_exception import NotFoundInDatabaseException
from backend.core.value_error_exception import ValueErrorException
from backend.open_food_facts.schemas import ProductDetails


class OpenFoodFactsService:
    def __init__(self):
        self.api = openfoodfacts.API(user_agent="Foodini/1.0")

    async def get_product_details_by_barcode(self, barcode: str) -> ProductDetails:
        if not await self._validate_check_sum(barcode):
            raise ValueErrorException("Invalid barcode checksum")

        response = self.api.product.get(
            barcode,
            fields=[
                "code",
                "product_name",
                "brands",
                "nutriments.carbohydrates_100g",
                "nutriments.energy-kcal_100g",
                "nutriments.fat_100g",
                "nutriments.proteins_100g",
            ],
        )

        if not response:
            raise NotFoundInDatabaseException("Scanned product not found in database")

        name = response.get("product_name", "")
        brands = response.get("brands", "")
        nutriments = response.get("nutriments", {})

        return ProductDetails(
            name=name if brands in name else f"{name} ({brands})",
            calories=round(int(response.get("energy-kcal_100g", 0))),
            protein=round(float(nutriments.get("proteins_100g", 0)), 2),
            fat=round(float(nutriments.get("fat_100g", 0)), 2),
            carbs=round(float(nutriments.get("carbohydrates_100g", 0)), 2),
        )

    @classmethod
    async def _validate_check_sum(cls, barcode: str) -> bool:
        if (len(barcode) != 13) or (not barcode.isdigit()):
            return False

        def digits_of(n):
            return [int(d) for d in str(n)]

        digits = digits_of(barcode)
        odd_digits = digits[-3::-2]
        even_digits = digits[-2::-2]
        checksum = sum(odd_digits + 3 * even_digits)
        return checksum % 10 == 10 - digits[-1]
