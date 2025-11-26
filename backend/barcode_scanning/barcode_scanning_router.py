from typing import Optional

import cv2
import numpy as np
from fastapi import APIRouter, Depends, File, Form, UploadFile

from backend.barcode_scanning.barcode_scanning_service import decode_ean13_from_image
from backend.open_food_facts.open_food_facts_gateway import OpenFoodFactsGateway, get_open_food_facts_gateway
from backend.users.user_gateway import UserGateway, get_user_gateway


barcode_scanning_router = APIRouter(prefix="/v1/meals")


@barcode_scanning_router.patch("/scanned-product")
async def add_scanned_product(
    barcode: Optional[str] = Form(None),
    image: Optional[UploadFile] = File(None),
    user_gateway: UserGateway = Depends(get_user_gateway),
    open_food_facts_gateway: OpenFoodFactsGateway = Depends(get_open_food_facts_gateway)
):
    await user_gateway.get_current_user()
    if not barcode and not image:
        return {"error": "Provide either barcode or image"}
    if barcode:
        return {"message": f"Processed barcode: {barcode}"}
    if image:
        content = await image.read()
        nparr = np.frombuffer(content, np.uint8)
        img = cv2.imdecode(nparr, cv2.IMREAD_GRAYSCALE)
        if img is None:
            return {"error": "Invalid image file"}

        try:
            decoded = decode_ean13_from_image(img)
        except Exception as e:
            return {"error": f"Failed to decode barcode: {str(e)}"}
        return {"message": f"Processed image barcode: {decoded}"}