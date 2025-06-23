from backend.models import User
from backend.user_details.schemas import PredictedCalories
from backend.user_details.service.calories_prediction_alghoritm import CaloriesPredictionAlgorithm
from backend.user_details.service.user_details_service import UserDetailsService


class CaloriesPredictionService:
    def __init__(self, user_details_service: UserDetailsService):
        self.user_details_service = user_details_service

    async def get_calories_prediction_by_user_id(self, token_payload: dict, user_id_from_request: int):
        raise NotImplementedError("To be implemented in the future")

    async def add_calories_prediction(
        self,
        user: User,
    ) -> PredictedCalories:
        user_details = await self.user_details_service.get_user_details_by_user(user)
        calories_prediction = CaloriesPredictionAlgorithm(user_details)
        return await calories_prediction.count_calories_prediction()

    async def update_calories_prediction(
        self,
        token_payload: dict,
    ):
        raise NotImplementedError("To be implemented in the future")
