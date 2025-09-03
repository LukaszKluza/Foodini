from fastapi import APIRouter, Depends

from backend.user_details.dependencies import get_calories_prediction_service
from backend.user_details.schemas import PredictedCalories
from backend.user_details.service.calories_prediction_service import CaloriesPredictionService
from backend.users.user_gateway import UserGateway, get_user_gateway

calories_prediction_router = APIRouter(prefix="/v1/calories-prediction")


@calories_prediction_router.post("/", response_model=PredictedCalories)
async def calories_prediction(
    calories_prediction_service: CaloriesPredictionService = Depends(get_calories_prediction_service),
    user_gateway: UserGateway = Depends(get_user_gateway),
):
    user, _ = await user_gateway.get_current_user()
    return await calories_prediction_service.add_calories_prediction(user)


@calories_prediction_router.get("/", response_model=PredictedCalories)
async def get_calories_prediction(
    calories_prediction_service: CaloriesPredictionService = Depends(get_calories_prediction_service),
    user_gateway: UserGateway = Depends(get_user_gateway),
):
    user, token_payload = await user_gateway.get_current_user()
    return await calories_prediction_service.get_calories_prediction_by_user_id(token_payload, user.id)
