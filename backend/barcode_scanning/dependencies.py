from fastapi import Depends

from backend.barcode_scanning.barcode_scanning_service import BarcodeScanningService
from backend.daily_summary.daily_summary_service import DailySummaryService
from backend.daily_summary.dependencies import get_daily_summary_service
from backend.open_food_facts.open_food_facts_gateway import (
    OpenFoodFactsGateway,
    get_open_food_facts_gateway,
)


async def get_barcode_scanning_service(
    open_food_facts_gateway: OpenFoodFactsGateway = Depends(get_open_food_facts_gateway),
    daily_summary_service: DailySummaryService = Depends(get_daily_summary_service),
) -> BarcodeScanningService:
    return BarcodeScanningService(open_food_facts_gateway, daily_summary_service)
