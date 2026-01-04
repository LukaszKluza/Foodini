from datetime import date
from typing import Optional

from fastapi import APIRouter, Depends, File, Form, UploadFile, Request

from backend.barcode_scanning.barcode_scanning_service import BarcodeScanningService
from backend.barcode_scanning.dependencies import get_barcode_scanning_service
from backend.core.role_sets import user_or_admin
from backend.meals.enums.meal_type import MealType
from backend.models import ComposedMealItem
from backend.users.user_gateway import UserGateway, get_user_gateway

barcode_scanning_router = APIRouter(prefix="/v1/barcode_scanning", tags=["User", "Admin"], dependencies=[user_or_admin])


@barcode_scanning_router.patch(
    "/scanned-product",
    response_model=ComposedMealItem,
    summary="Add scanned product",
    description="Adds a product identified by barcode fetched from image or given by user to the "
    "proper daily meal summary.",
)
async def add_scanned_product(
    request: Request,
    day: date = Form(...),
    meal_type: MealType = Form(...),
    barcode: Optional[str] = Form(None),
    image: Optional[UploadFile] = File(None),
    user_gateway: UserGateway = Depends(get_user_gateway),
    scanning_service: BarcodeScanningService = Depends(get_barcode_scanning_service),
):
    user, _ = await user_gateway.get_current_user()
    return await scanning_service.process_scan(user, day, meal_type, barcode, image)
