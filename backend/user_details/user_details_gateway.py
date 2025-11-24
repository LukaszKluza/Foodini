from datetime import datetime

from fastapi import Depends

from backend.models import User, UserDetails
from backend.user_details.dependencies import get_calories_prediction_service, get_user_details_service
from backend.user_details.schemas import PredictedCalories
from backend.user_details.service.calories_prediction_service import CaloriesPredictionService
from backend.user_details.service.user_details_service import UserDetailsService


class UserDetailsGateway:
    def __init__(
        self, user_details_service: UserDetailsService, calories_prediction_service: CaloriesPredictionService
    ):
        self.user_details_service = user_details_service
        self.calories_prediction_service = calories_prediction_service

    async def get_user_details(self, user: User) -> UserDetails:
        return await self.user_details_service.get_user_details_by_user(user)

    async def get_date_of_last_update_user_details(self, user: User) -> datetime:
        return await self.user_details_service.get_date_of_last_update_user_details(user)

    async def get_user_diet_predictions(self, user: User) -> PredictedCalories:
        return await self.calories_prediction_service.get_calories_prediction_by_user_id(user.id)

    async def get_date_of_last_update_user_calories_prediction(self, user: User) -> datetime:
        return await self.calories_prediction_service.get_date_of_last_update_user_calories_prediction(user.id)


def get_user_details_gateway(
    user_details_service: UserDetailsService = Depends(get_user_details_service),
    calories_prediction_service: CaloriesPredictionService = Depends(get_calories_prediction_service),
) -> UserDetailsGateway:
    return UserDetailsGateway(user_details_service, calories_prediction_service)
