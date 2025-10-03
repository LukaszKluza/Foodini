from backend.diet_prediction.diet_prediction_service import MealIconsService
from fastapi import APIRouter, Depends

from backend.diet_prediction.dependencies import get_meal_icons_service
from backend.diet_prediction.enums.meal_type import MealType
from backend.models.meal_icon_model import MealIcon
from backend.users.user_gateway import UserGateway, get_user_gateway

diet_prediction_router = APIRouter(prefix="/v1/diet-prediction")


@diet_prediction_router.get("/meal-icon", response_model=MealIcon)
async def get_meal_icon_info(
    meal_type: MealType,
    meal_icons_service: MealIconsService = Depends(get_meal_icons_service),
    user_gateway: UserGateway = Depends(get_user_gateway),
):
    await user_gateway.get_current_user()
    return await meal_icons_service.get_meal_icon(meal_type)
