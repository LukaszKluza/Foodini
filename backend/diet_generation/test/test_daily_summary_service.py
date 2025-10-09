import sys
from datetime import date
from unittest.mock import AsyncMock, MagicMock, patch

import pytest

from backend.core.not_found_in_database_exception import NotFoundInDatabaseException
from backend.diet_generation.schemas import (
    CustomMealUpdateRequest,
    DailyMacrosSummaryCreate,
    DailyMealsCreate,
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
def daily_summary_service(mock_daily_summary_repository):
    return DailySummaryService(mock_daily_summary_repository)


@pytest.mark.asyncio
async def test_add_daily_meals_success(daily_summary_service, mock_daily_summary_repository):
    daily_meals = DailyMealsCreate(day=date.today(), meals={})
    mock_daily_summary_repository.get_daily_meals.return_value = None
    mock_daily_summary_repository.add_daily_meals.return_value = daily_meals

    result = await daily_summary_service.add_daily_meals(daily_meals, user_id=1)

    assert result == daily_meals
    mock_daily_summary_repository.add_daily_meals.assert_called_once()


@pytest.mark.asyncio
async def test_add_daily_meals_already_exists(daily_summary_service, mock_daily_summary_repository):
    daily_meals = DailyMealsCreate(day=date.today(), meals={})
    mock_daily_summary_repository.get_daily_meals.return_value = daily_meals

    with pytest.raises(ValueError):
        await daily_summary_service.add_daily_meals(daily_meals, user_id=1)


@pytest.mark.asyncio
async def test_get_daily_meals_success(daily_summary_service, mock_daily_summary_repository):
    daily_meals = DailyMealsCreate(day=date.today(), meals={})
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
    mock_daily_summary_repository.get_daily_macros_summary.return_value = summary

    with pytest.raises(ValueError):
        await daily_summary_service.add_daily_macros_summary(user_id=1, data=summary)


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


@pytest.mark.asyncio
async def test_update_daily_macros_summary_success(daily_summary_service, mock_daily_summary_repository):
    summary = DailyMacrosSummaryCreate(day=date.today(), calories=2000)
    mock_daily_summary_repository.update_daily_macros_summary.return_value = summary

    result = await daily_summary_service.update_daily_macros_summary(user_id=1, data=summary)

    assert result == summary
    mock_daily_summary_repository.update_daily_macros_summary.assert_called_once()


@pytest.mark.asyncio
async def test_update_daily_macros_summary_not_found(daily_summary_service, mock_daily_summary_repository):
    summary = DailyMacrosSummaryCreate(day=date.today())
    mock_daily_summary_repository.update_daily_macros_summary.return_value = None

    with pytest.raises(NotFoundInDatabaseException):
        await daily_summary_service.update_daily_macros_summary(user_id=1, data=summary)


@pytest.mark.asyncio
async def test_update_meal_status_success(daily_summary_service, mock_daily_summary_repository):
    update = MealInfoUpdateRequest(day=date.today(), meal_type="breakfast", status="eaten")
    daily_meals = DailyMealsCreate(day=date.today(), meals={})
    mock_daily_summary_repository.update_meal_status.return_value = daily_meals

    result = await daily_summary_service.update_meal_status(user_id=1, update_data=update)

    assert result == daily_meals
    mock_daily_summary_repository.update_meal_status.assert_called_once()


@pytest.mark.asyncio
async def test_update_meal_status_not_found(daily_summary_service, mock_daily_summary_repository):
    update = MealInfoUpdateRequest(day=date.today(), meal_type="breakfast", status="eaten")
    mock_daily_summary_repository.update_meal_status.return_value = None

    with pytest.raises(NotFoundInDatabaseException):
        await daily_summary_service.update_meal_status(user_id=1, update_data=update)


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
    daily_meals = DailyMealsCreate(day=date.today(), meals={})
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
    mock_daily_summary_repository.add_custom_meal.return_value = None

    with pytest.raises(NotFoundInDatabaseException):
        await daily_summary_service.add_custom_meal(user_id=1, custom_meal=custom)
