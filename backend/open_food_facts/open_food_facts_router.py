from fastapi import APIRouter, Depends

from backend.open_food_facts.dependencies import get_open_food_facts_service
from backend.open_food_facts.open_food_facts_service import OpenFoodFactsService
from backend.users.user_gateway import UserGateway, get_user_gateway

open_food_facts_router = APIRouter(prefix="/v1/open-food-facts")


@open_food_facts_router.get(
    "/{product_barcode}",
    summary="Get product details by barcode",
    description="Retrieves detailed information about a food product using its barcode "
    "from the Open Food Facts database.",
)
async def get_meal_recipe_by_meal_id(
    product_barcode: str,
    open_food_facts_service: OpenFoodFactsService = Depends(get_open_food_facts_service),
    user_gateway: UserGateway = Depends(get_user_gateway),
):
    await user_gateway.get_current_user()
    return await open_food_facts_service.get_product_details_by_barcode(product_barcode)
