from fastapi import Depends

from backend.open_food_facts.dependencies import get_open_food_facts_service
from backend.open_food_facts.open_food_facts_service import OpenFoodFactsService
from backend.open_food_facts.schemas import ProductDetails


class OpenFoodFactsGateway:
    def __init__(self, open_food_facts_service: OpenFoodFactsService):
        self.open_food_facts_service = open_food_facts_service

    async def get_product_details_by_barcode(self, barcode: str) -> ProductDetails:
        return await self.open_food_facts_service.get_product_details_by_barcode(barcode)

def get_open_food_facts_gateway(
    open_food_facts_service: OpenFoodFactsService = Depends(get_open_food_facts_service),
) -> OpenFoodFactsGateway:
    return OpenFoodFactsGateway(open_food_facts_service)
