from backend.models import User
from backend.user_details.calories_prediction_repository import CaloriesPredictionRepository
from backend.user_details.schemas import PredictedCalories, PredictedMacros
from backend.user_details.service.calories_prediction_algorithm import CaloriesPredictionAlgorithm
from backend.user_details.service.user_details_service import UserDetailsService


class CaloriesPredictionService:
    def __init__(
        self, user_details_service: UserDetailsService, calories_prediction_repository: CaloriesPredictionRepository
    ):
        self.user_details_service = user_details_service
        self.calories_prediction_repository = calories_prediction_repository

    async def get_calories_prediction_by_user_id(self, user_id_from_request: int):
        return await self.calories_prediction_repository.get_user_calories_prediction_by_user_id(user_id_from_request)

    async def add_calories_prediction(
        self,
        user: User,
    ):
        user_details = await self.user_details_service.get_user_details_by_user(user)
        calories_prediction: PredictedCalories = await CaloriesPredictionAlgorithm(
            user_details
        ).count_calories_prediction()
        return await self.calories_prediction_repository.add_user_calories_prediction(user.id, calories_prediction)

    async def update_macros_prediction(
        self,
        changed_macros: PredictedMacros,
        user_id: int,
    ):
        return await self.calories_prediction_repository.update_macros_prediction(changed_macros, user_id)
