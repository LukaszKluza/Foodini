from datetime import date

import pytest

from backend.diet_generation.diet_valdiation_service import DietValidationService
from backend.diet_generation.enums.meal_type import MealType
from backend.diet_generation.schemas import DailyMealsCreate, MealCreate, MealInfo
from backend.models import Ingredient, Ingredients, MealRecipe, Step, UserDetails, UserDietPredictions
from backend.users.enums.language import Language


@pytest.mark.asyncio
async def test_should_validate_macros_returns_true_if_meals_macros_meet_user_diet_predictions():
    # Given
    user_diet_predictions = UserDietPredictions(target_calories=2263, protein=120, carbs=250, fat=60)

    meals = await create_set_of_5_meals()

    # When
    response = DietValidationService._validate_macros(user_diet_predictions, meals)

    # Then
    assert response is True


@pytest.mark.asyncio
async def test_should_validate_macros_returns_true_if_macros_difference_within_threshold():
    # Given
    user_diet_predictions = UserDietPredictions(target_calories=2293, protein=111, carbs=259, fat=61)

    meals = await create_set_of_5_meals()

    # When
    response = DietValidationService._validate_macros(user_diet_predictions, meals)

    # Then
    assert response is True


@pytest.mark.asyncio
@pytest.mark.parametrize(
    "user_diet_predictions,expected_error",
    [
        (
            UserDietPredictions(target_calories=1893, protein=111, carbs=259, fat=61),
            "Calories mismatch: 2263 vs target 1893",
        ),
        (
            UserDietPredictions(target_calories=2293, protein=151, carbs=259, fat=61),
            "Protein mismatch: 120 vs target 151",
        ),
        (
            UserDietPredictions(target_calories=2293, protein=120, carbs=219, fat=61),
            "Carbs mismatch: 250 vs target 219",
        ),
        (
            UserDietPredictions(target_calories=2293, protein=120, carbs=250, fat=89),
            "Fat mismatch: 60 vs target 89",
        ),
    ],
)
async def test_validate_macros_should_raise_value_error(user_diet_predictions, expected_error):
    # Given
    meals = await create_set_of_5_meals()

    # When / Then
    with pytest.raises(ValueError, match=expected_error):
        DietValidationService._validate_macros(user_diet_predictions, meals)


@pytest.mark.asyncio
@pytest.mark.parametrize(
    "meals_per_day,meals,expected_exception,expected_message",
    [
        (
            5,
            {
                MealType.BREAKFAST: MealInfo(meal_id=1),
                MealType.MORNING_SNACK: MealInfo(meal_id=2),
                MealType.LUNCH: MealInfo(meal_id=3),
                MealType.AFTERNOON_SNACK: MealInfo(meal_id=4),
                MealType.DINNER: MealInfo(meal_id=5),
            },
            None,
            None,
        ),
        (
            6,
            {
                MealType.BREAKFAST: MealInfo(meal_id=1),
                MealType.MORNING_SNACK: MealInfo(meal_id=2),
                MealType.LUNCH: MealInfo(meal_id=3),
                MealType.AFTERNOON_SNACK: MealInfo(meal_id=4),
                MealType.DINNER: MealInfo(meal_id=5),
            },
            ValueError,
            "Invalid number of meals: expected 6, got 5",
        ),
        (
            4,
            {
                MealType.BREAKFAST: MealInfo(meal_id=1),
                MealType.MORNING_SNACK: MealInfo(meal_id=2),
                MealType.LUNCH: MealInfo(meal_id=3),
                MealType.AFTERNOON_SNACK: MealInfo(meal_id=4),
                MealType.DINNER: MealInfo(meal_id=5),
            },
            ValueError,
            "Invalid number of meals: expected 4, got 5",
        ),
        (
            5,
            {
                MealType.BREAKFAST: MealInfo(meal_id=1),
                MealType.MORNING_SNACK: MealInfo(meal_id=2),
                MealType.LUNCH: MealInfo(meal_id=3),
                MealType.AFTERNOON_SNACK: MealInfo(meal_id=4),
                MealType.EVENING_SNACK: MealInfo(meal_id=5),
            },
            ValueError,
            "Meal types mismatch",
        ),
    ],
)
async def test_validate_number_and_type_of_meals(meals_per_day, meals, expected_exception, expected_message):
    # Given
    user_details = UserDetails(meals_per_day=meals_per_day)
    daily_meals = DailyMealsCreate(
        day=date(2024, 1, 1), meals=meals, target_calories=1893, target_protein=111, target_carbs=259, target_fats=61
    )

    # When / Then
    if expected_exception:
        with pytest.raises(expected_exception, match=expected_message):
            DietValidationService._validate_number_and_type_of_meals(user_details, daily_meals)
    else:
        assert DietValidationService._validate_number_and_type_of_meals(user_details, daily_meals) is True


@pytest.mark.asyncio
@pytest.mark.parametrize(
    "ingredients,steps,expected_exception,expected_message",
    [
        ([], [Step(description="Pour the cornflakes into a bowl.")], ValueError, "Invalid number of ingredients: 0"),
        ([Ingredient(volume=1, unit="cup", name="cornflakes")], [], ValueError, "Invalid number of steps: 0"),
        (
            [Ingredient(volume=1, unit="cup", name="cornflakes")],
            [Step(description="Pour the cornflakes into a bowl.")],
            None,
            None,
        ),
    ],
)
async def test_validate_meal_recipe(ingredients, steps, expected_exception, expected_message):
    meal_recipe = MealRecipe(
        id=1,
        meal_id=1,
        language=Language.EN,
        meal_name="Cornflakes with soy milk",
        meal_type=MealType.BREAKFAST,
        meal_description="Crispy cornflakes served with smooth, creamy soy milk. "
        "A light, nutritious breakfast perfect for a quick start to your day",
        icon_id=1,
        ingredients=Ingredients(
            ingredients=ingredients,
            food_additives="sugar, honey, fruits, or nut",
        ),
        steps=steps,
    )

    if expected_exception:
        with pytest.raises(expected_exception, match=expected_message):
            DietValidationService._validate_meal_recipe(meal_recipe)
    else:
        assert DietValidationService._validate_meal_recipe(meal_recipe) is True


async def create_set_of_5_meals():
    return [
        MealCreate(
            meal_name="Meal 1", meal_type=MealType.BREAKFAST, icon_id=1, calories=432, protein=23, carbs=56, fat=12
        ),
        MealCreate(
            meal_name="Meal 2", meal_type=MealType.MORNING_SNACK, icon_id=2, calories=380, protein=20, carbs=49, fat=11
        ),
        MealCreate(meal_name="Meal 3", meal_type=MealType.LUNCH, icon_id=3, calories=670, protein=36, carbs=87, fat=18),
        MealCreate(
            meal_name="Meal 4", meal_type=MealType.AFTERNOON_SNACK, icon_id=4, calories=249, protein=13, carbs=32, fat=7
        ),
        MealCreate(
            meal_name="Meal 5", meal_type=MealType.DINNER, icon_id=5, calories=532, protein=28, carbs=26, fat=12
        ),
    ]
