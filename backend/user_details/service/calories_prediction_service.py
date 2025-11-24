from typing import Type
from uuid import UUID

from pydantic import ValidationError

from backend.core.custom_exception_code import CustomExceptionCode
from backend.core.logger import logger
from backend.core.not_found_in_database_exception import NotFoundInDatabaseException
from backend.models import User, UserDietPredictions
from backend.settings import config
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

    async def get_calories_prediction_by_user_id(self, user_id_from_request: UUID):
        calories_prediction_result = await self.calories_prediction_repository.get_user_calories_prediction_by_user_id(
            user_id_from_request
        )
        if not calories_prediction_result:
            logger.debug(f"No calorie prediction found for the user: {user_id_from_request}.")
            raise NotFoundInDatabaseException(
                "No calorie prediction found for the user.", code=CustomExceptionCode.MISSING_DIET_PREDICTIONS
            )
        return PredictedCalories.from_user_diet_predictions(calories_prediction_result)

    async def get_date_of_last_update_user_calories_prediction(self, user_id_from_request: UUID):
        last_update = await self.calories_prediction_repository.get_date_of_last_update_user_calories_prediction(
            user_id_from_request
        )
        if not last_update:
            logger.debug(f"No date of last update calories predictions the user: {user_id_from_request}.")
            raise NotFoundInDatabaseException("No date of last update calories predictions the user.")
        return last_update

    async def add_calories_prediction(
        self,
        user: Type[User],
    ):
        user_details = await self.user_details_service.get_user_details_by_user(user)
        calories_prediction_result: PredictedCalories = await CaloriesPredictionAlgorithm(
            user_details
        ).count_calories_prediction()
        return await self.calories_prediction_repository.add_user_calories_prediction(
            user.id, calories_prediction_result
        )

    async def update_macros_prediction(
        self,
        changed_macros: PredictedMacros,
        user_id: UUID,
    ):
        user_diet_predictions = await self.calories_prediction_repository.get_diet_prediction_by_user_id(user_id)
        if user_diet_predictions is None:
            logger.debug(f"No calorie prediction found for the user: {user_id}.")
            raise NotFoundInDatabaseException("No calorie prediction found for the user.")

        await self.validate_changed_macros(changed_macros, user_diet_predictions)

        return await self.calories_prediction_repository.update_macros_prediction(changed_macros, user_id)

    @staticmethod
    async def validate_changed_macros(changed_macros: PredictedMacros, user_diet_predictions: UserDietPredictions):
        user_calories = user_diet_predictions.target_calories

        if changed_macros.protein <= 0 or changed_macros.fat <= 0 or changed_macros.carbs <= 0:
            logger.debug(f"Macros cannot be negative or zero, changedMacros: {changed_macros}.")
            raise ValidationError("Macros cannot be negative or zero.")

        approx_new_calories = (
            changed_macros.protein * config.PROTEIN_CONVERSION_FACTOR
            + changed_macros.fat * config.FAT_CONVERSION_FACTOR
            + changed_macros.carbs * config.CARBS_CONVERSION_FACTOR
        )

        if abs(approx_new_calories - user_calories) > config.MACROS_CHANGE_TOLERANCE:
            logger.debug(
                f"New macros are too far from predicted calories, approxNew_Calories: {approx_new_calories},"
                f" userCalories: {user_calories}, macrosChangedTolerance: {config.MACROS_CHANGE_TOLERANCE}."
            )
            raise ValidationError("New macros are too far from predicted calories")
