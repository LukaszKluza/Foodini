import sys
import uuid
from datetime import date
from unittest.mock import AsyncMock, MagicMock, patch

import pytest

from backend.core.not_found_in_database_exception import NotFoundInDatabaseException
from backend.daily_summary.enums.meal_status import MealStatus
from backend.daily_summary.schemas import (
    CustomMealUpdateRequest,
    DailyMacrosSummaryCreate,
    MealInfo,
    MealInfoUpdateRequest,
)
from backend.meals.enums.meal_type import MealType
from backend.meals.schemas import MealCreate
from backend.meals.test.test_data import MEAL_ICON_ID, MEAL_ID
from backend.models import User

with patch.dict(sys.modules, {"backend.diet_generation.daily_summary_repository": MagicMock()}):
    from backend.daily_summary.daily_summary_service import DailySummaryService


class MockDailyMealLink:
    def __init__(self, meal_id=MEAL_ID, meal_type=MealType.BREAKFAST, status=MealStatus.TO_EAT):
        self.meal_id = meal_id
        self.meal = MagicMock()
        self.meal.id = meal_id
        self.meal.meal_type = meal_type
        self.meal.calories = 100
        self.meal.protein = 10
        self.meal.carbs = 20
        self.meal.fat = 5
        self.status = status
        self.meal.custom_name = None
        mock_recipe = MagicMock()
        mock_recipe.meal_name = "Test meal"
        mock_recipe.meal_description = "Delicious mock meal"
        self.meal.recipes = [mock_recipe]


class MockDailyMealsSummary:
    def __init__(self):
        self.day = date.today()
        self.daily_meals = [
            MockDailyMealLink(uuid.UUID("6ea7ae4d-fc73-4db0-987d-84e8e2bc2a6a"), MealType.BREAKFAST),
            MockDailyMealLink(uuid.UUID("6ea7ae4d-fc73-4db0-987d-84e8e2bc2a6b"), MealType.LUNCH),
            MockDailyMealLink(uuid.UUID("6ea7ae4d-fc73-4db0-987d-84e8e2bc2a6c"), MealType.DINNER),
        ]
        self.target_calories = 2000
        self.target_protein = 150
        self.target_carbs = 250
        self.target_fat = 70
        self.user_id = user.id


class MockDailyBaseInfo:
    def __init__(self):
        self.calories = 100
        self.protein = 10
        self.carbs = 20
        self.fat = 5
        self.meal_id = uuid.UUID("6ea7ae4d-fc73-4db0-987d-84e8e2bc2a6a")
        self.status = MealStatus.TO_EAT


@pytest.fixture
def mock_daily_summary_repository():
    repo = AsyncMock()
    repo.get_daily_summary = AsyncMock()
    repo.get_daily_meals_summary = AsyncMock()
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
    repo.get_meal_fat_by_id = AsyncMock()
    return repo


@pytest.fixture
def mock_last_generated_meals_repository():
    repo = AsyncMock()
    repo.get_last_generated_meals = AsyncMock()
    return repo


@pytest.fixture
def mock_meal_gateway():
    gateway = AsyncMock()
    gateway.add_meal_recipe = AsyncMock()
    return gateway


@pytest.fixture
def daily_summary_service(
    mock_daily_summary_repository, mock_meal_repository, mock_last_generated_meals_repository, mock_meal_gateway
):
    return DailySummaryService(
        mock_daily_summary_repository, mock_meal_repository, mock_last_generated_meals_repository, mock_meal_gateway
    )


user = User(id=uuid.UUID("6ea7ae4d-fc73-4db0-987d-84e8e2bc2a6a"))


@pytest.mark.asyncio
async def test_get_daily_meals_success(daily_summary_service, mock_daily_summary_repository):
    mock_summary = MockDailyMealsSummary()
    mock_daily_summary_repository.get_daily_meals_summary.return_value = mock_summary

    result = await daily_summary_service.get_daily_meals(user_id=uuid.uuid4(), day=date.today())

    assert result.day == mock_summary.day
    assert result.target_calories == mock_summary.target_calories
    assert isinstance(result.meals, dict)
    assert list(result.meals.values())[0].calories == 100


@pytest.mark.asyncio
async def test_get_daily_meals_not_found(daily_summary_service, mock_daily_summary_repository):
    mock_daily_summary_repository.get_daily_meals_summary.return_value = None

    with pytest.raises(NotFoundInDatabaseException):
        await daily_summary_service.get_daily_meals(user_id=uuid.uuid4(), day=date.today())


@pytest.mark.asyncio
async def test_add_daily_macros_summary_success(daily_summary_service, mock_daily_summary_repository):
    summary = DailyMacrosSummaryCreate(day=date.today(), calories=2000, protein=100, carbs=200, fat=70)
    mock_daily_summary_repository.get_daily_macros_summary.return_value = None
    mock_daily_summary_repository.add_daily_macros_summary.return_value = summary

    result = await daily_summary_service.add_daily_macros_summary(
        user_id=uuid.UUID("6ea7ae4d-fc73-4db0-987d-84e8e2bc2a6a"), data=summary
    )

    assert result == summary
    mock_daily_summary_repository.add_daily_macros_summary.assert_called_once()


@pytest.mark.asyncio
async def test_add_daily_macros_summary_already_exists(daily_summary_service, mock_daily_summary_repository):
    summary = DailyMacrosSummaryCreate(day=date.today(), calories=2000, protein=100, carbs=200, fat=70)
    updated_summary = DailyMacrosSummaryCreate(day=date.today(), calories=0, protein=0, carbs=0, fat=0)
    mock_daily_summary_repository.get_daily_macros_summary.return_value = summary
    mock_daily_summary_repository.update_daily_macros_summary.return_value = updated_summary

    result = await daily_summary_service.add_daily_macros_summary(
        user_id=uuid.UUID("6ea7ae4d-fc73-4db0-987d-84e8e2bc2a6a"), data=updated_summary
    )

    assert result == updated_summary
    mock_daily_summary_repository.get_daily_macros_summary.assert_called_once()
    mock_daily_summary_repository.update_daily_macros_summary.assert_called_once()


@pytest.mark.asyncio
async def test_get_daily_macros_summary_success(daily_summary_service, mock_daily_summary_repository):
    summary = DailyMacrosSummaryCreate(day=date.today(), calories=2000)
    mock_daily_summary_repository.get_daily_macros_summary.return_value = summary

    result = await daily_summary_service.get_daily_macros_summary(
        user_id=uuid.UUID("6ea7ae4d-fc73-4db0-987d-84e8e2bc2a6a"), day=date.today()
    )

    assert result == summary


@pytest.mark.asyncio
async def test_get_daily_macros_summary_not_found(daily_summary_service, mock_daily_summary_repository):
    mock_daily_summary_repository.get_daily_macros_summary.return_value = None

    with pytest.raises(NotFoundInDatabaseException):
        await daily_summary_service.get_daily_macros_summary(
            user_id=uuid.UUID("6ea7ae4d-fc73-4db0-987d-84e8e2bc2a6a"), day=date.today()
        )


@pytest.mark.asyncio
async def test_update_meal_status_success(daily_summary_service, mock_daily_summary_repository):
    mock_daily_base_info = MockDailyBaseInfo()
    mock_summary = MockDailyMealsSummary()
    mock_daily_summary_repository.get_daily_meals_summary.return_value = mock_summary

    update = MealInfoUpdateRequest(day=date.today(), meal_id=mock_daily_base_info.meal_id, status=MealStatus.EATEN)

    daily_summary_service._add_macros_after_status_change = AsyncMock()
    daily_summary_service._update_next_meal_status = AsyncMock()

    result = await daily_summary_service.update_meal_status(
        user=user,
        update_meal_data=update,
    )

    mock_daily_summary_repository.get_daily_meals_summary.assert_awaited_once_with(user.id, date.today())
    mock_daily_summary_repository.update_meal_status.assert_awaited_once_with(
        user.id,
        date.today(),
        update.meal_id,
        update.status,
    )
    daily_summary_service._add_macros_after_status_change.assert_awaited_once()
    daily_summary_service._update_next_meal_status.assert_awaited_once()

    assert result.status == MealStatus.EATEN
    assert result.calories == mock_daily_base_info.calories
    assert result.protein == mock_daily_base_info.protein
    assert result.carbs == mock_daily_base_info.carbs
    assert result.fat == mock_daily_base_info.fat


@pytest.mark.asyncio
async def test_update_meal_status_not_found(daily_summary_service, mock_daily_summary_repository):
    mock_daily_summary_repository.get_daily_meals_summary.return_value = None

    update = MealInfoUpdateRequest(day=date.today(), meal_id=MEAL_ID, status=MealStatus.EATEN)

    with pytest.raises(NotFoundInDatabaseException):
        await daily_summary_service.update_meal_status(user=user, update_meal_data=update)


@pytest.mark.asyncio
async def test_update_meal_status_adds_macros_when_eaten(
    daily_summary_service, mock_daily_summary_repository, mock_meal_repository
):
    today = date.today()

    mock_summary = MockDailyMealsSummary()
    first_meal = mock_summary.daily_meals[0]
    first_meal.status = MealStatus.TO_EAT

    mock_daily_summary_repository.get_daily_meals_summary.return_value = mock_summary
    mock_daily_summary_repository.update_meal_status = AsyncMock()

    daily_summary_service._add_macros_to_daily_summary = AsyncMock()
    daily_summary_service._update_next_meal_status = AsyncMock()

    update_request = MealInfoUpdateRequest(
        day=today,
        meal_id=first_meal.meal_id,
        status=MealStatus.EATEN,
    )

    await daily_summary_service.update_meal_status(
        user=user,
        update_meal_data=update_request,
    )

    mock_daily_summary_repository.update_meal_status.assert_awaited_once_with(
        user.id, today, first_meal.meal_id, MealStatus.EATEN
    )

    daily_summary_service._add_macros_to_daily_summary.assert_awaited_once()
    called_data = daily_summary_service._add_macros_to_daily_summary.call_args[0][1]

    assert isinstance(called_data, DailyMacrosSummaryCreate)
    assert called_data.calories == first_meal.meal.calories
    assert called_data.protein == first_meal.meal.protein
    assert called_data.carbs == first_meal.meal.carbs
    assert called_data.fat == first_meal.meal.fat


@pytest.mark.asyncio
async def test_add_custom_meal_success(daily_summary_service, mock_daily_summary_repository, mock_meal_repository):
    meal_id = uuid.UUID("6ea7ae4d-fc73-4db0-987d-84e8e2bc2a6a")

    custom = CustomMealUpdateRequest(
        day=date.today(),
        meal_id=meal_id,
        custom_name="Omelette",
        custom_calories=300,
        custom_protein=20,
        custom_carbs=5,
        custom_fat=15,
        status=MealStatus.EATEN,
    )

    mock_summary = MockDailyMealsSummary()
    breakfast_link = mock_summary.daily_meals[0]
    breakfast_link.status = MealStatus.TO_EAT
    breakfast_link.meal.icon_id = MEAL_ICON_ID

    mock_daily_summary_repository.get_daily_summary = AsyncMock(return_value=mock_summary)

    new_meal = AsyncMock()
    new_meal.id = uuid.uuid4()
    new_meal.fat = 70
    new_meal.calories = 300
    new_meal.protein = 150
    new_meal.carbs = 250
    mock_meal_repository.add_meal = AsyncMock(return_value=new_meal)

    daily_summary_service._add_macros_after_status_change = AsyncMock()
    updated_plan = MockDailyMealsSummary()
    mock_daily_summary_repository.add_meal = AsyncMock(return_value=updated_plan)

    result = await daily_summary_service.add_custom_meal(user=user, custom_meal=custom)

    mock_meal_repository.add_meal.assert_awaited_once()

    assert isinstance(result, MealInfo)
    assert result.status == MealStatus.TO_EAT
    assert result.calories == custom.custom_calories
    assert result.protein == float(updated_plan.target_protein)
    assert result.carbs == float(updated_plan.target_carbs)
    assert result.fat == float(updated_plan.target_fat)


# @pytest.mark.asyncio
# async def test_add_custom_meal_not_found(daily_summary_service, mock_daily_summary_repository):
#     # given
#     meal_id = uuid.UUID("6ea7ae4d-fc73-4db0-987d-84e8e2bc2a6a")
#     today = date.today()
#     custom = CustomMealUpdateRequest(
#         day=today,
#         meal_id=meal_id,
#         custom_name="Omelette",
#         custom_calories=300,
#         custom_protein=20,
#         custom_carbs=5,
#         custom_fat=15,
#         status=MealStatus.EATEN,
#     )

#     # brak planu dnia dla użytkownika
#     mock_daily_summary_repository.get_daily_meals_summary = AsyncMock(return_value=None)

#     # when / then
#     with pytest.raises(NotFoundInDatabaseException, match="Plan for given user and day does not exist."):
#         await daily_summary_service.add_custom_meal(user=user, custom_meal=custom)

#     mock_daily_summary_repository.get_daily_meals_summary.assert_awaited_once_with(user, today)


# @pytest.mark.asyncio
# async def test_add_custom_meal_without_name(
#   daily_summary_service,
#   mock_daily_summary_repository,
#   mock_meal_repository
# ):
#     meal_id = uuid.UUID("6ea7ae4d-fc73-4db0-987d-84e8e2bc2a6a")
#     today = date.today()
#     custom = CustomMealUpdateRequest(
#         day=today,
#         meal_id=meal_id,
#         custom_name=None,
#         custom_calories=350,
#         custom_protein=25,
#         custom_carbs=10,
#         custom_fat=15,
#         status=MealStatus.EATEN,
#     )

#     existing_meal = MagicMock()
#     existing_meal.id = uuid.uuid4()
#     existing_meal.meal_type = MealType.BREAKFAST
#     existing_meal.icon_id = MEAL_ICON_ID
#     existing_meal.calories = 300
#     existing_meal.protein = 20
#     existing_meal.carbs = 5
#     existing_meal.fat = 10

#     existing_link = MagicMock()
#     existing_link.meal = existing_meal
#     existing_link.status = MealStatus.TO_EAT.value

#     daily_meals_mock = MagicMock()
#     daily_meals_mock.daily_meals = [existing_link]

#     mock_daily_summary_repository.get_daily_meals_summary = AsyncMock(return_value=daily_meals_mock)

#     new_meal = MagicMock()
#     new_meal.id = uuid.uuid4()
#     new_meal.meal_type = MealType.BREAKFAST
#     new_meal.icon_id = existing_meal.icon_id
#     mock_meal_repository.add_meal = AsyncMock(return_value=new_meal)

#     updated_plan = MagicMock()
#     updated_plan.day = today
#     updated_plan.daily_meals = [existing_link]
#     updated_plan.target_calories = 0
#     updated_plan.target_protein = 0
#     updated_plan.target_carbs = 0
#     updated_plan.target_fat = 0
#     mock_daily_summary_repository.add_custom_meal = AsyncMock(return_value=updated_plan)

#     result = await daily_summary_service.add_custom_meal(
#         user=user,
#         custom_meal=custom,
#     )

#     mock_daily_summary_repository.get_daily_meals_summary.assert_awaited_once_with(user, today)
#     mock_meal_repository.add_meal.assert_awaited_once()
#     mock_daily_summary_repository.add_custom_meal.assert_awaited_once()

#     assert isinstance(result, DailyMealsCreate)


@pytest.mark.asyncio
async def test_add_meal_details_add_new(daily_summary_service, mock_meal_repository):
    meal_data = MealCreate(
        calories=300,
        protein=20,
        carbs=5,
        fat=15,
        meal_type=MealType.BREAKFAST,
        icon_id=MEAL_ICON_ID,
    )
    mock_meal_repository.add_meal.return_value = meal_data

    result = await daily_summary_service.add_meal_details(meal_data)

    assert result == meal_data
    mock_meal_repository.add_meal.assert_awaited_once_with(meal_data)
    mock_meal_repository.update_meal.assert_not_called()


@pytest.mark.asyncio
async def test_get_meal_details_success(daily_summary_service, mock_meal_repository):
    meal_data = MealCreate(
        calories=300,
        protein=20,
        carbs=5,
        fat=15,
        meal_type=MealType.BREAKFAST,
        icon_id=MEAL_ICON_ID,
    )
    mock_meal_repository.get_meal_by_id.return_value = meal_data

    result = await daily_summary_service.get_meal_details(MEAL_ID)

    assert result == meal_data
    mock_meal_repository.get_meal_by_id.assert_awaited_once_with(MEAL_ID)


@pytest.mark.asyncio
async def test_get_meal_details_not_found(daily_summary_service, mock_meal_repository):
    mock_meal_repository.get_meal_by_id.return_value = None

    with pytest.raises(NotFoundInDatabaseException):
        await daily_summary_service.get_meal_details(MEAL_ID)


@pytest.mark.asyncio
async def test_get_meal_calories_success(daily_summary_service, mock_meal_repository):
    mock_meal_repository.get_meal_calories_by_id.return_value = 300

    result = await daily_summary_service._get_meal_calories(MEAL_ID)

    assert result == 300
    mock_meal_repository.get_meal_calories_by_id.assert_awaited_once_with(MEAL_ID)


@pytest.mark.asyncio
async def test_get_meal_calories_not_found(daily_summary_service, mock_meal_repository):
    mock_meal_repository.get_meal_calories_by_id.return_value = None

    with pytest.raises(NotFoundInDatabaseException):
        await daily_summary_service._get_meal_calories(MEAL_ID)


@pytest.mark.asyncio
async def test_get_meal_macros_success(daily_summary_service, mock_meal_repository):
    mock_meal_repository.get_meal_protein_by_id.return_value = 20
    mock_meal_repository.get_meal_fat_by_id.return_value = 15
    mock_meal_repository.get_meal_carbs_by_id.return_value = 5

    result = await daily_summary_service._get_meal_macros(MEAL_ID)

    assert result == {"protein": 20, "fat": 15, "carbs": 5}


@pytest.mark.asyncio
async def test_get_meal_macros_not_found(daily_summary_service, mock_meal_repository):
    mock_meal_repository.get_meal_protein_by_id.return_value = None
    mock_meal_repository.get_meal_fats_by_id.return_value = None
    mock_meal_repository.get_meal_carbs_by_id.return_value = None

    with pytest.raises(NotFoundInDatabaseException):
        await daily_summary_service._get_meal_macros(MEAL_ID)
