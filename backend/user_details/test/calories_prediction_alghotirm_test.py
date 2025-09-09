import logging

import pytest

from backend.models import UserDetails
from backend.user_details.schemas import PredictedCalories, PredictedMacros
from backend.user_details.service.calories_prediction_algorithm import CaloriesPredictionAlgorithm

from . import test_data

logging.basicConfig(level=logging.DEBUG)


@pytest.mark.parametrize(
    "user,expected",
    [
        (
            test_data.user_1,
            PredictedCalories(
                bmr=1521,
                tdee=2065,
                target_calories=2272,
                diet_duration_days=186,
                predicted_macros=PredictedMacros(protein=117, fat=75, carbs=280),
            ),
        ),
        (
            test_data.user_2,
            PredictedCalories(
                bmr=1345,
                tdee=2195,
                target_calories=1646,
                diet_duration_days=70,
                predicted_macros=PredictedMacros(protein=143, fat=36, carbs=186),
            ),
        ),
    ],
)
@pytest.mark.asyncio
async def test_calories_prediction_algorithm(user: UserDetails, expected: PredictedCalories):
    # Given
    calories_prediction_algorithm = CaloriesPredictionAlgorithm(user)

    # When
    prediction = await calories_prediction_algorithm.count_calories_prediction()

    # Then
    assert prediction == expected
