from typing import List, Optional
from uuid import UUID

import cv2
import numpy as np
from fastapi import APIRouter, Depends, File, Form, Query, UploadFile

from backend.barcode_scanning.barcode_scanning_service import decode_ean13_from_image
from backend.meals.dependencies import get_meal_service
from backend.meals.enums.meal_type import MealType
from backend.meals.meal_service import MealService
from backend.meals.schemas import MealRecipeResponse
from backend.models.meal_icon_model import MealIcon
from backend.users.enums.language import Language
from backend.users.user_gateway import UserGateway, get_user_gateway

meal_router = APIRouter(prefix="/v1/meals")


@meal_router.get("/meal-icon", response_model=MealIcon)
async def get_meal_icon_info(
    meal_type: MealType,
    meal_service: MealService = Depends(get_meal_service),
    user_gateway: UserGateway = Depends(get_user_gateway),
):
    await user_gateway.get_current_user()
    return await meal_service.get_meal_icon(meal_type)


@meal_router.get("/meal-recipes/{meal_id}", response_model=MealRecipeResponse | List[MealRecipeResponse])
async def get_meal_recipe_by_meal_id(
    meal_id: UUID,
    language: Optional[Language] = Query(None),
    meal_service: MealService = Depends(get_meal_service),
    user_gateway: UserGateway = Depends(get_user_gateway),
):
    await user_gateway.get_current_user()
    if language:
        return await meal_service.get_meal_recipe_by_meal_recipe_id_and_language(meal_id, language)
    return await meal_service.get_meal_recipes_by_meal_recipe_id(meal_id)


@meal_router.patch("/scanned-product")
async def add_scanned_product(
    barcode: Optional[str] = Form(None),
    image: Optional[UploadFile] = File(None),
    user_gateway: UserGateway = Depends(get_user_gateway),
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
