from backend.open_food_facts.open_food_facts_service import OpenFoodFactsService


async def get_open_food_facts_service() -> OpenFoodFactsService:
    return OpenFoodFactsService()
