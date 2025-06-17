from fastapi import APIRouter, Depends, status
from fastapi.params import Query

from backend.core.user_authorisation_service import AuthorizationService
from backend.user_details.service.user_details_service import UserDetailsService
from backend.user_details.dependencies import get_calories_prediction_service
from backend.user_details.schemas import PredictedCalories
from backend.users.user_gateway import UserGateway, get_user_gateway
from backend.user_details.service.calories_prediction_service import CaloriesPredictionService


calories_prediction_router = APIRouter(prefix="/v1/calories_prediction")


@calories_prediction_router.post("/", response_model=PredictedCalories)
async def calories_prediction(
    calories_prediction_service: CaloriesPredictionService = Depends(get_calories_prediction_service),
    user_gateway: UserGateway = Depends(get_user_gateway),
):
    user, _ = await user_gateway.get_current_user()
    return await calories_prediction_service.add_calories_prediction(user)

