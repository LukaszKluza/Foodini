from fastapi import APIRouter, Depends

from backend.user_details.dependencies import get_calories_prediction_service
from backend.user_details.schemas import PredictedCalories, PredictedMacros
from backend.user_details.service.calories_prediction_service import CaloriesPredictionService
from backend.users.user_gateway import UserGateway, get_user_gateway

calories_prediction_router = APIRouter(prefix="/v1/calories-prediction")


@calories_prediction_router.post(
    "/",
    response_model=PredictedCalories,
    summary="Add calories prediction",
    description="Save calories predicted for the currently authenticated user based on user details.",
)
async def calories_prediction(
    calories_prediction_service: CaloriesPredictionService = Depends(get_calories_prediction_service),
    user_gateway: UserGateway = Depends(get_user_gateway),
):
    user, _ = await user_gateway.get_current_user()
    return await calories_prediction_service.add_calories_prediction(user)


@calories_prediction_router.patch(
    "/",
    response_model=PredictedCalories,
    summary="Update macros prediction",
    description="Update macronutrients predicted for the currently authenticated user based on user details "
    "and validate they match the predicted calories.",
)
async def update_macros_prediction(
    changed_macros: PredictedMacros,
    calories_prediction_service: CaloriesPredictionService = Depends(get_calories_prediction_service),
    user_gateway: UserGateway = Depends(get_user_gateway),
):
    user, _ = await user_gateway.get_current_user()
    return await calories_prediction_service.update_macros_prediction(changed_macros, user.id)


@calories_prediction_router.get(
    "/",
    response_model=PredictedCalories,
    summary="Get calories prediction",
    description="Retrieves calories predicted for the currently authenticated user based on user details.",
)
async def get_calories_prediction(
    calories_prediction_service: CaloriesPredictionService = Depends(get_calories_prediction_service),
    user_gateway: UserGateway = Depends(get_user_gateway),
):
    user, _ = await user_gateway.get_current_user()
    return await calories_prediction_service.get_calories_prediction_by_user_id(user.id)
