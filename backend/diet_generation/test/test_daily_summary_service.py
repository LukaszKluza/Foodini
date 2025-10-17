import sys
from datetime import date
from unittest.mock import AsyncMock, MagicMock, patch

import pytest

from backend.core.not_found_in_database_exception import NotFoundInDatabaseException
from backend.diet_generation.enums.meal_status import MealStatus
from backend.diet_generation.enums.meal_type import MealType
from backend.diet_generation.schemas import (
    CustomMealUpdateRequest,
    DailyMacrosSummaryCreate,
    DailyMealsCreate,
    MealCreate,
    MealInfoUpdateRequest,
)

with patch.dict(sys.modules, {"backend.diet_generation.daily_summary_repository": MagicMock()}):
    from backend.diet_generation.daily_summary_service import DailySummaryService


@pytest.fixture
def mock_daily_summary_repository():
    repo = AsyncMock()
    repo.get_daily_meals = AsyncMock()
    repo.add_daily_meals = AsyncMock()
    repo.get_daily_macros_summary = AsyncMock()
    repo.add_daily_macros_summary = AsyncMock()
    repo.update_daily_macros_summary = AsyncMock()
    repo.update_meal_status = AsyncMock()
    repo.update_custom_meal = AsyncMock()
    return repo


@pytest.fixture
def mock_meal_repository():
    repo = AsyncMock()
    repo.add_meal = AsyncMock()
    repo.update_meal = AsyncMock()
    repo.get_meal_by_id = AsyncMock()
    repo.get_meal_by_name = AsyncMock()
    repo.get_meal_calories_by_id = AsyncMock()
    repo.get_meal_protein_by_id = AsyncMock()
    repo.get_meal_carbs_by_id = AsyncMock()
    repo.get_meal_fats_by_id = AsyncMock()
    return repo


@pytest.fixture
def daily_summary_service(mock_daily_summary_repository, mock_meal_repository):
    return DailySummaryService(mock_daily_summary_repository, mock_meal_repository)


@pytest.mark.asyncio
async def test_add_daily_meals_success(daily_summary_service, mock_daily_summary_repository):
    daily_meals = DailyMealsCreate(
        day=date.today(), meals={}, target_calories=0, target_protein=0, target_carbs=0, target_fats=0
    )
    mock_daily_summary_repository.get_daily_meals.return_value = None
    mock_daily_summary_repository.add_daily_meals.return_value = daily_meals

    result = await daily_summary_service.add_daily_meals(daily_meals, user_id=1)

    assert result == daily_meals
    mock_daily_summary_repository.add_daily_meals.assert_called_once()


@pytest.mark.asyncio
async def test_add_daily_meals_already_exists(daily_summary_service, mock_daily_summary_repository):
    daily_meals = DailyMealsCreate(
        day=date.today(), meals={}, target_calories=0, target_protein=0, target_carbs=0, target_fats=0
    )
    updated_meals = DailyMealsCreate(
        day=date.today(), meals={}, target_calories=2, target_protein=3, target_carbs=4, target_fats=5
    )
    mock_daily_summary_repository.get_daily_meals.return_value = daily_meals
    mock_daily_summary_repository.update_daily_meals.return_value = updated_meals

    result = await daily_summary_service.add_daily_meals(updated_meals, user_id=1)

    assert result == updated_meals
    mock_daily_summary_repository.get_daily_meals.assert_called_once()
    mock_daily_summary_repository.update_daily_meals.assert_called_once()


@pytest.mark.asyncio
async def test_get_daily_meals_success(daily_summary_service, mock_daily_summary_repository):
    daily_meals = DailyMealsCreate(
        day=date.today(), meals={}, target_calories=0, target_protein=0, target_carbs=0, target_fats=0
    )
    mock_daily_summary_repository.get_daily_meals.return_value = daily_meals

    result = await daily_summary_service.get_daily_meals(user_id=1, day=date.today())

    assert result == daily_meals


@pytest.mark.asyncio
async def test_get_daily_meals_not_found(daily_summary_service, mock_daily_summary_repository):
    mock_daily_summary_repository.get_daily_meals.return_value = None

    with pytest.raises(NotFoundInDatabaseException):
        await daily_summary_service.get_daily_meals(user_id=1, day=date.today())


@pytest.mark.asyncio
async def test_add_daily_macros_summary_success(daily_summary_service, mock_daily_summary_repository):
    summary = DailyMacrosSummaryCreate(day=date.today(), calories=2000, protein=100, carbs=200, fats=70)
    mock_daily_summary_repository.get_daily_macros_summary.return_value = None
    mock_daily_summary_repository.add_daily_macros_summary.return_value = summary

    result = await daily_summary_service.add_daily_macros_summary(user_id=1, data=summary)

    assert result == summary
    mock_daily_summary_repository.add_daily_macros_summary.assert_called_once()


@pytest.mark.asyncio
async def test_add_daily_macros_summary_already_exists(daily_summary_service, mock_daily_summary_repository):
    summary = DailyMacrosSummaryCreate(day=date.today(), calories=2000, protein=100, carbs=200, fats=70)
    updated_summary = DailyMacrosSummaryCreate(day=date.today(), calories=0, protein=0, carbs=0, fats=0)
    mock_daily_summary_repository.get_daily_macros_summary.return_value = summary
    mock_daily_summary_repository.update_daily_macros_summary.return_value = updated_summary

    result = await daily_summary_service.add_daily_macros_summary(user_id=1, data=updated_summary)

    assert result == updated_summary
    mock_daily_summary_repository.get_daily_macros_summary.assert_called_once()
    mock_daily_summary_repository.update_daily_macros_summary.assert_called_once()


@pytest.mark.asyncio
async def test_get_daily_macros_summary_success(daily_summary_service, mock_daily_summary_repository):
    summary = DailyMacrosSummaryCreate(day=date.today(), calories=2000)
    mock_daily_summary_repository.get_daily_macros_summary.return_value = summary

    result = await daily_summary_service.get_daily_macros_summary(user_id=1, day=date.today())

    assert result == summary


@pytest.mark.asyncio
async def test_get_daily_macros_summary_not_found(daily_summary_service, mock_daily_summary_repository):
    mock_daily_summary_repository.get_daily_macros_summary.return_value = None

    with pytest.raises(NotFoundInDatabaseException):
        await daily_summary_service.get_daily_macros_summary(user_id=1, day=date.today())


# @pytest.mark.asyncio
# async def test_update_daily_macros_summary_success(daily_summary_service, mock_daily_summary_repository):
#     summary = DailyMacrosSummaryCreate(day=date.today(), calories=2000, protein=80, carbs=170, fats=55)
#
#     mock_daily_summary_repository.get_daily_macros_summary.return_value = DailyMacrosSummaryCreate(
#         day=date.today(), calories=1500, protein=50, carbs=150, fats=50
#     )
#     mock_daily_summary_repository.update_daily_macros_summary.return_value = None
#
#     result = await daily_summary_service.update_daily_macros_summary(user_id=1, data=summary)
#
#     assert result.calories == 2000
#     assert result.protein == 80
#     assert result.carbs == 170
#     assert result.fats == 55
#     mock_daily_summary_repository.get_daily_macros_summary.assert_awaited_once_with(1, date.today())
#     mock_daily_summary_repository.update_daily_macros_summary.assert_awaited_once_with(1, date.today(), result)


# @pytest.mark.asyncio
# async def test_update_daily_macros_summary_not_found(daily_summary_service, mock_daily_summary_repository):
#     summary = DailyMacrosSummaryCreate(day=date.today())
#     mock_daily_summary_repository.get_daily_macros_summary.return_value = None
#
#     with pytest.raises(NotFoundInDatabaseException):
#         await daily_summary_service.update_daily_macros_summary(user_id=1, data=summary)


@pytest.mark.asyncio
async def test_update_meal_status_success(daily_summary_service, mock_daily_summary_repository):
    user_daily_meals = MagicMock()
    user_daily_meals.meals = {
        "breakfast": {"status": MealStatus.TO_EAT.value, "meal_id": 1},
        "lunch": {"status": MealStatus.TO_EAT.value, "meal_id": 2},
        "dinner": {"status": MealStatus.TO_EAT.value, "meal_id": 3},
    }
    mock_daily_summary_repository.get_daily_meals.return_value = user_daily_meals

    update = MealInfoUpdateRequest(day=date.today(), meal_type=MealType.BREAKFAST, status=MealStatus.EATEN)
    expected_meals = {
        "breakfast": {"status": MealStatus.EATEN.value, "meal_id": 1},
        "lunch": {"status": MealStatus.PENDING.value, "meal_id": 2},
        "dinner": {"status": MealStatus.TO_EAT.value, "meal_id": 3},
    }

    updated_meals = DailyMealsCreate(
        day=date.today(),
        meals=expected_meals,
        target_calories=0,
        target_protein=0,
        target_carbs=0,
        target_fats=0,
    )
    mock_daily_summary_repository.update_meal_status.return_value = updated_meals

    result = await daily_summary_service.update_meal_status(user_id=1, update_meal_data=update)

    assert result == updated_meals
    mock_daily_summary_repository.get_daily_meals.assert_awaited_once_with(1, date.today())
    mock_daily_summary_repository.update_meal_status.assert_awaited_once_with(1, date.today(), expected_meals)


@pytest.mark.asyncio
async def test_update_meal_status_not_found(daily_summary_service, mock_daily_summary_repository):
    update = MealInfoUpdateRequest(day=date.today(), meal_type="breakfast", status="eaten")
    mock_daily_summary_repository.update_meal_status.return_value = None

    with pytest.raises(NotFoundInDatabaseException):
        await daily_summary_service.update_meal_status(user_id=1, update_meal_data=update)


@pytest.mark.asyncio
async def test_update_meal_status_adds_macros_when_eaten(
    daily_summary_service, mock_daily_summary_repository, mock_meal_repository
):
    daily_meals_mock = MagicMock()
    daily_meals_mock.meals = {
        MealType.BREAKFAST.value: {
            "meal_id": 1,
            "status": MealStatus.TO_EAT.value,
            "custom_calories": None,
            "custom_protein": None,
            "custom_carbs": None,
            "custom_fats": None,
        }
    }
    mock_daily_summary_repository.get_daily_meals.return_value = daily_meals_mock

    mock_meal_repository.get_meal_calories_by_id.return_value = 300
    mock_meal_repository.get_meal_protein_by_id.return_value = 20
    mock_meal_repository.get_meal_carbs_by_id.return_value = 30
    mock_meal_repository.get_meal_fats_by_id.return_value = 10

    daily_summary_service.get_meal_calories = AsyncMock(return_value=300)
    daily_summary_service.get_meal_macros = AsyncMock(return_value={"protein": 20, "carbs": 30, "fats": 10})
    daily_summary_service.add_macros_to_daily_summary = AsyncMock()

    update_request = MealInfoUpdateRequest(
        day=date.today(),
        meal_type=MealType.BREAKFAST,
        status=MealStatus.EATEN,
    )

    await daily_summary_service.update_meal_status(user_id=1, update_meal_data=update_request)

    daily_summary_service.add_macros_to_daily_summary.assert_awaited_once()
    called_data = daily_summary_service.add_macros_to_daily_summary.call_args[0][1]
    assert isinstance(called_data, DailyMacrosSummaryCreate)
    assert called_data.calories == 300
    assert called_data.protein == 20
    assert called_data.carbs == 30
    assert called_data.fats == 10

    assert daily_meals_mock.meals[MealType.BREAKFAST.value]["status"] == MealStatus.EATEN.value


@pytest.mark.asyncio
async def test_add_custom_meal_success(daily_summary_service, mock_daily_summary_repository):
    custom = CustomMealUpdateRequest(
        day=date.today(),
        meal_type="breakfast",
        custom_name="Omelette",
        custom_calories=300,
        custom_protein=20,
        custom_carbs=5,
        custom_fats=15,
        status="eaten",
    )
    daily_meals = DailyMealsCreate(
        day=date.today(), meals={}, target_calories=0, target_protein=0, target_carbs=0, target_fats=0
    )
    mock_daily_summary_repository.add_custom_meal.return_value = daily_meals

    result = await daily_summary_service.add_custom_meal(user_id=1, custom_meal=custom)

    assert result == daily_meals
    mock_daily_summary_repository.add_custom_meal.assert_called_once()


@pytest.mark.asyncio
async def test_add_custom_meal_not_found(daily_summary_service, mock_daily_summary_repository):
    custom = CustomMealUpdateRequest(
        day=date.today(),
        meal_type="breakfast",
        custom_name="Omelette",
        custom_calories=300,
        custom_protein=20,
        custom_carbs=5,
        custom_fats=15,
        status="eaten",
    )
    mock_daily_summary_repository.get_daily_meals.return_value = None

    with pytest.raises(NotFoundInDatabaseException):
        await daily_summary_service.add_custom_meal(user_id=1, custom_meal=custom)
    mock_daily_summary_repository.get_daily_meals.assert_awaited_once_with(1, custom.day)


@pytest.mark.asyncio
async def test_add_custom_meal_without_name(daily_summary_service, mock_daily_summary_repository):
    custom = CustomMealUpdateRequest(
        day=date.today(),
        meal_type=MealType.BREAKFAST,
        custom_name=None,
        custom_calories=350,
        custom_protein=25,
        custom_carbs=10,
        custom_fats=15,
        status=MealStatus.EATEN,
    )

    existing_meal_info = {
        "meal_id": 1,
        "status": MealStatus.TO_EAT.value,
        "custom_calories": 300,
        "custom_protein": 20,
        "custom_carbs": 5,
        "custom_fats": 10,
    }

    daily_meals_mock = MagicMock()
    daily_meals_mock.meals = {MealType.BREAKFAST.value: existing_meal_info}

    mock_daily_summary_repository.get_daily_meals.return_value = daily_meals_mock

    updated_plan = DailyMealsCreate(
        day=date.today(),
        meals={
            MealType.BREAKFAST.value: {
                "meal_id": 1,
                "status": MealStatus.EATEN.value,
                "custom_calories": 350,
                "custom_protein": 25,
                "custom_carbs": 10,
                "custom_fats": 15,
            }
        },
        target_calories=0,
        target_protein=0,
        target_carbs=0,
        target_fats=0,
    )
    mock_daily_summary_repository.add_custom_meal.return_value = updated_plan

    result = await daily_summary_service.add_custom_meal(user_id=1, custom_meal=custom)

    assert result == updated_plan
    mock_daily_summary_repository.get_daily_meals.assert_awaited_once_with(1, custom.day)
    mock_daily_summary_repository.add_custom_meal.assert_awaited_once_with(
        1,
        custom.day,
        {
            MealType.BREAKFAST.value: {
                "meal_id": 1,
                "status": MealStatus.EATEN.value,
                "custom_calories": 350,
                "custom_protein": 25,
                "custom_carbs": 10,
                "custom_fats": 15,
            }
        },
    )


@pytest.mark.asyncio
async def test_add_meal_details_add_new(daily_summary_service, mock_meal_repository):
    meal_data = MealCreate(
        meal_name="Omelette", calories=300, protein=20, carbs=5, fats=15, meal_type="BREAKFAST", icon_id=1
    )
    mock_meal_repository.get_meal_by_name.return_value = None
    mock_meal_repository.add_meal.return_value = meal_data

    result = await daily_summary_service.add_meal_details(meal_data)

    assert result == meal_data
    mock_meal_repository.get_meal_by_name.assert_awaited_once_with("Omelette")
    mock_meal_repository.add_meal.assert_awaited_once_with(meal_data)
    mock_meal_repository.update_meal.assert_not_called()


@pytest.mark.asyncio
async def test_add_meal_details_update_existing(daily_summary_service, mock_meal_repository):
    meal_data = MealCreate(
        meal_name="Omelette", calories=300, protein=20, carbs=5, fats=15, meal_type="BREAKFAST", icon_id=1
    )
    mock_meal_repository.get_meal_by_name.return_value = meal_data
    mock_meal_repository.update_meal.return_value = meal_data

    result = await daily_summary_service.add_meal_details(meal_data)

    assert result == meal_data
    mock_meal_repository.get_meal_by_name.assert_awaited_once_with("Omelette")
    mock_meal_repository.update_meal.assert_awaited_once_with(meal_data)
    mock_meal_repository.add_meal.assert_not_called()


@pytest.mark.asyncio
async def test_get_meal_details_success(daily_summary_service, mock_meal_repository):
    meal_id = 1
    meal_data = MealCreate(
        meal_name="Omelette", calories=300, protein=20, carbs=5, fats=15, meal_type="BREAKFAST", icon_id=1
    )
    mock_meal_repository.get_meal_by_id.return_value = meal_data

    result = await daily_summary_service.get_meal_details(meal_id)

    assert result == meal_data
    mock_meal_repository.get_meal_by_id.assert_awaited_once_with(meal_id)


@pytest.mark.asyncio
async def test_get_meal_details_not_found(daily_summary_service, mock_meal_repository):
    meal_id = 1
    mock_meal_repository.get_meal_by_id.return_value = None

    with pytest.raises(NotFoundInDatabaseException):
        await daily_summary_service.get_meal_details(meal_id)


@pytest.mark.asyncio
async def test_get_meal_calories_success(daily_summary_service, mock_meal_repository):
    meal_id = 1
    mock_meal_repository.get_meal_calories_by_id.return_value = 300

    result = await daily_summary_service.get_meal_calories(meal_id)

    assert result == 300
    mock_meal_repository.get_meal_calories_by_id.assert_awaited_once_with(meal_id)


@pytest.mark.asyncio
async def test_get_meal_calories_not_found(daily_summary_service, mock_meal_repository):
    meal_id = 1
    mock_meal_repository.get_meal_calories_by_id.return_value = None

    with pytest.raises(NotFoundInDatabaseException):
        await daily_summary_service.get_meal_calories(meal_id)


@pytest.mark.asyncio
async def test_get_meal_macros_success(daily_summary_service, mock_meal_repository):
    meal_id = 1
    mock_meal_repository.get_meal_protein_by_id.return_value = 20
    mock_meal_repository.get_meal_fats_by_id.return_value = 15
    mock_meal_repository.get_meal_carbs_by_id.return_value = 5

    result = await daily_summary_service.get_meal_macros(meal_id)

    assert result == {"protein": 20, "fats": 15, "carbs": 5}


@pytest.mark.asyncio
async def test_get_meal_macros_not_found(daily_summary_service, mock_meal_repository):
    meal_id = 1
    mock_meal_repository.get_meal_protein_by_id.return_value = None
    mock_meal_repository.get_meal_fats_by_id.return_value = None
    mock_meal_repository.get_meal_carbs_by_id.return_value = None

    with pytest.raises(NotFoundInDatabaseException):
        await daily_summary_service.get_meal_macros(meal_id)
