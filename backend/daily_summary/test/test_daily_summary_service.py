import sys
import uuid
from datetime import date
from unittest.mock import AsyncMock, MagicMock, patch

import pytest

from backend.core.not_found_in_database_exception import NotFoundInDatabaseException
from backend.daily_summary.enums.meal_status import MealStatus
from backend.daily_summary.schemas import DailyMacrosSummaryCreate, MealInfoUpdateRequest, RemoveMealRequest
from backend.meals.enums.meal_type import MealType
from backend.meals.schemas import MealCreate
from backend.meals.test.test_data import MEAL_ICON_ID, MEAL_ID
from backend.models import User

with patch.dict(sys.modules, {"backend.diet_generation.daily_summary_repository": MagicMock()}):
    from backend.daily_summary.daily_summary_service import DailySummaryService


class MockDailyMealLink:
    def __init__(self, meal_id=MEAL_ID, meal_type=MealType.BREAKFAST, status=MealStatus.TO_EAT):
        self.meal_id = meal_id
        self.status = status
        self.meal_type = meal_type
        self.is_generated = True
        self.meal_items = []

        mock_meal = MagicMock()
        mock_meal.id = meal_id
        mock_meal.meal_type = meal_type
        mock_meal.weight = 500
        mock_meal.calories = 100
        mock_meal.protein = 10
        mock_meal.carbs = 20
        mock_meal.fat = 5
        mock_meal.icon_id = MEAL_ICON_ID

        mock_recipe = MagicMock()
        mock_recipe.meal_name = "Test meal"
        mock_recipe.meal_description = "Delicious mock meal"
        mock_recipe.meal_explanation = "Mock explanation"
        mock_meal.recipes = [mock_recipe]

        composed_item = MagicMock()
        composed_item.meal_id = meal_id
        composed_item.meal = mock_meal
        composed_item.weight_eaten = 500

        self.meal_items.append(composed_item)


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


class MockMealRecipe:
    def __init__(self):
        self.meal_name = "Meal name"
        self.meal_description = "Meal description"
        self.meal_explanation = "Meal explanation"


class MockDailyBaseInfo:
    def __init__(self):
        self.calories = 100
        self.protein = 10
        self.carbs = 20
        self.fat = 5
        self.weight = 500
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
def mock_composed_meal_items_repo():
    repo = AsyncMock()
    repo.get_composed_meal_item_by_user_id_and_meal_id = AsyncMock()
    return repo


@pytest.fixture
def mock_meal_gateway():
    gateway = AsyncMock()
    gateway.add_meal_recipe = AsyncMock()
    gateway.get_meal_recipe_by_meal_and_language_safe = AsyncMock()
    return gateway


@pytest.fixture
def mock_user_details_gateway():
    gateway = AsyncMock()
    gateway.get_date_of_last_update_user_details = AsyncMock()
    gateway.get_date_of_last_update_user_calories_prediction = AsyncMock()
    return gateway


@pytest.fixture
def daily_summary_service(
    mock_daily_summary_repository,
    mock_meal_repository,
    mock_last_generated_meals_repository,
    mock_composed_meal_items_repo,
    mock_meal_gateway,
    mock_user_details_gateway,
):
    return DailySummaryService(
        mock_daily_summary_repository,
        mock_meal_repository,
        mock_last_generated_meals_repository,
        mock_composed_meal_items_repo,
        mock_meal_gateway,
        mock_user_details_gateway,
    )


user = User(id=uuid.UUID("6ea7ae4d-fc73-4db0-987d-84e8e2bc2a6a"))


@pytest.mark.asyncio
async def test_get_daily_meals_success(daily_summary_service, mock_daily_summary_repository, mock_meal_gateway):
    mock_summary = MockDailyMealsSummary()
    mock_recipe = MockMealRecipe()
    mock_daily_summary_repository.get_daily_meals_summary.return_value = mock_summary
    mock_meal_gateway.get_meal_icon_path_by_id.return_value = "mock_icon_path.png"
    mock_meal_gateway.get_meal_recipe_by_meal_and_language_safe.return_value = mock_recipe

    result = await daily_summary_service.get_daily_meals(user=user, day=date.today())

    assert result.day == mock_summary.day
    assert result.target_calories == mock_summary.target_calories
    assert isinstance(result.meals, dict)
    assert list(result.meals.values())[0][0].calories == 100


@pytest.mark.asyncio
async def test_get_daily_meals_not_found(daily_summary_service, mock_daily_summary_repository):
    mock_daily_summary_repository.get_daily_meals_summary.return_value = None

    with pytest.raises(NotFoundInDatabaseException):
        await daily_summary_service.get_daily_meals(user=user, day=date.today())


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


# @pytest.mark.asyncio
# async def test_update_meal_status_success(daily_summary_service, mock_daily_summary_repository, mock_meal_repository):
#     mock_daily_base_info = MockDailyBaseInfo()
#     mock_summary = MockDailyMealsSummary()
#     mock_daily_summary_repository.get_daily_meals_summary.return_value = mock_summary
#
#     first_meal = mock_summary.daily_meals[0]
#     first_meal.meal_items[0].meal = mock_daily_base_info
#
#     mock_daily_summary_repository.get_daily_macros_summary.return_value = MagicMock(
#         calories=1000, protein=100, carbs=200, fat=50
#     )
#     mock_daily_summary_repository.update_daily_macros_summary.return_value = MagicMock()
#
#     update = MealInfoUpdateRequest(day=date.today(), meal_type=MealType.BREAKFAST, status=MealStatus.EATEN)
#
#     result = await daily_summary_service.update_meal_status(
#         user=user,
#         update_meal_data=update,
#     )
#
#     mock_daily_summary_repository.get_daily_meals_summary.assert_awaited_once_with(user.id, date.today())
#     mock_daily_summary_repository.update_meal_status.assert_awaited_once_with(
#         user.id,
#         date.today(),
#         update.meal_type,
#         update.status,
#     )
#     mock_daily_summary_repository.update_daily_macros_summary.assert_awaited_once()
#
#     assert result.calories == mock_daily_base_info.calories
#     assert result.protein == mock_daily_base_info.protein
#     assert result.carbs == mock_daily_base_info.carbs
#     assert result.fat == mock_daily_base_info.fat


@pytest.mark.asyncio
async def test_update_meal_status_not_found(daily_summary_service, mock_daily_summary_repository):
    mock_daily_summary_repository.get_daily_meals_summary.return_value = None

    update = MealInfoUpdateRequest(day=date.today(), meal_type=MealType.BREAKFAST, status=MealStatus.EATEN)

    with pytest.raises(NotFoundInDatabaseException):
        await daily_summary_service.update_meal_status(user=user, update_meal_data=update)


# @pytest.mark.asyncio
# async def test_update_meal_status_adds_macros_when_eaten(
#     daily_summary_service, mock_daily_summary_repository, mock_meal_repository
# ):
#     today = date.today()
#
#     mock_summary = MockDailyMealsSummary()
#     first_meal = mock_summary.daily_meals[0]
#     first_meal.status = MealStatus.TO_EAT
#
#     first_meal.meal_items[0].meal = MockDailyBaseInfo()
#
#     mock_daily_summary_repository.get_daily_meals_summary.return_value = mock_summary
#     mock_daily_summary_repository.update_meal_status = AsyncMock()
#
#     mock_daily_summary_repository.get_daily_macros_summary.return_value = MagicMock(
#         calories=1000, protein=100, carbs=200, fat=50
#     )
#     mock_daily_summary_repository.update_daily_macros_summary.return_value = MagicMock()
#
#     update_request = MealInfoUpdateRequest(
#         day=today,
#         meal_type=MealType.BREAKFAST,
#         status=MealStatus.EATEN,
#     )
#
#     await daily_summary_service.update_meal_status(
#         user=user,
#         update_meal_data=update_request,
#     )
#
#     mock_daily_summary_repository.update_meal_status.assert_awaited_once_with(
#         user.id, today, MealType.BREAKFAST, MealStatus.EATEN
#     )
#
#     mock_daily_summary_repository.update_daily_macros_summary.assert_awaited_once()
#     called_data = mock_daily_summary_repository.update_daily_macros_summary.call_args[0][1]
#
#     assert isinstance(called_data, DailyMacrosSummaryCreate)
#     assert called_data.calories == 1100
#     assert called_data.protein == 110
#     assert called_data.carbs == 220
#     assert called_data.fat == 55
#
#
# @pytest.mark.asyncio
# async def test_add_custom_meal_success(
#     daily_summary_service,
#     mock_daily_summary_repository,
#     mock_meal_repository,
#     mock_composed_meal_items_repo
# ):
#     meal_id = uuid.UUID("6ea7ae4d-fc73-4db0-987d-84e8e2bc2a6a")
#
#     custom = CustomMealUpdateRequest(
#         day=date.today(),
#         meal_id=meal_id,
#         custom_name="Omelette",
#         custom_calories=300,
#         custom_protein=20,
#         custom_carbs=5,
#         custom_fat=15,
#         status=MealStatus.EATEN,
#         meal_type=MealType.BREAKFAST,
#     )
#
#     mock_summary = MockDailyMealsSummary()
#     breakfast_link = mock_summary.daily_meals[0]
#     breakfast_link.status = MealStatus.TO_EAT
#     breakfast_link.meal_items[0].meal.icon_id = MEAL_ICON_ID
#
#     mock_daily_summary_repository.get_daily_summary.return_value = mock_summary
#
#     mock_composed_meal_items_repo.get_composed_meal_item_by_user_id_and_meal_id.return_value = None
#
#     new_meal = MagicMock()
#     new_meal.id = uuid.uuid4()
#     new_meal.fat = 15
#     new_meal.calories = 300
#     new_meal.protein = 20
#     new_meal.carbs = 5
#     new_meal.weight = 100
#     mock_meal_repository.update_meal_by_id = AsyncMock(return_value=new_meal)
#     mock_meal_repository.add_meal = AsyncMock(return_value=new_meal)
#
#     mock_daily_summary_repository.get_daily_macros_summary.return_value = MagicMock(
#         calories=1000, protein=100, carbs=200, fat=50
#     )
#     mock_daily_summary_repository.update_daily_macros_summary.return_value = MagicMock()
#
#     mock_daily_summary_repository.add_custom_meal.return_value = mock_summary
#
#     result = await daily_summary_service.add_custom_meal(user=user, custom_meal=custom)
#
#     mock_daily_summary_repository.get_daily_summary.assert_awaited_once()
#     mock_meal_repository.add_meal.assert_awaited_once()
#     mock_daily_summary_repository.add_custom_meal.assert_awaited_once()
#
#     assert isinstance(result, MealInfo)
#     assert result.status == MealStatus.TO_EAT
#     assert result.calories == custom.custom_calories
#     assert result.protein == custom.custom_protein
#     assert result.carbs == custom.custom_carbs
#     assert result.fat == custom.custom_fat
#
#
# @pytest.mark.asyncio
# async def test_add_custom_meal_not_found(
#     daily_summary_service,
#     mock_daily_summary_repository,
#     mock_composed_meal_items_repo
# ):
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
#         meal_type=MealType.BREAKFAST,
#     )
#
#     mock_daily_summary_repository.get_daily_summary.return_value = None
#     mock_composed_meal_items_repo.get_composed_meal_item_by_user_id_and_meal_id.return_value = None
#
#     with pytest.raises(NotFoundInDatabaseException, match="Plan for given user and day does not exist."):
#         await daily_summary_service.add_custom_meal(user=user, custom_meal=custom)
#
#     mock_daily_summary_repository.get_daily_summary.assert_awaited_once_with(user.id, today)
#
#
# @pytest.mark.asyncio
# async def test_add_custom_meal_without_name(
#     daily_summary_service,
#     mock_daily_summary_repository,
#     mock_meal_repository,
#     mock_composed_meal_items_repo
# ):
#     meal_id = uuid.UUID("6ea7ae4d-fc73-4db0-987d-84e8e2bc2a6a")
#     today = date.today()
#     custom = CustomMealUpdateRequest(
#         day=today,
#         meal_type=MealType.BREAKFAST,
#         meal_id=meal_id,
#         custom_name=None,
#         custom_calories=350,
#         custom_protein=25,
#         custom_carbs=10,
#         custom_fat=15,
#     )
#
#     existing_meal = MagicMock()
#     existing_meal.id = meal_id
#     existing_meal.meal_type = MealType.BREAKFAST
#     existing_meal.icon_id = MEAL_ICON_ID
#     existing_meal.calories = 300
#     existing_meal.protein = 20
#     existing_meal.carbs = 5
#     existing_meal.fat = 10
#     existing_meal.weight = 100
#     existing_meal.meal_name = "Fish with onion rings"
#     existing_meal.is_generated = False
#
#     mock_meal_item = MagicMock()
#     mock_meal_item.meal_id = meal_id
#     mock_meal_item.meal = existing_meal
#
#     mock_meal_link = MagicMock()
#     mock_meal_link.meal_type = MealType.BREAKFAST
#     mock_meal_link.status = MealStatus.TO_EAT
#     mock_meal_link.meal_items = [mock_meal_item]
#
#     mock_summary = MagicMock()
#     mock_summary.daily_meals = [mock_meal_link]
#
#     mock_daily_summary_repository.get_daily_summary.return_value = mock_summary
#     mock_composed_meal_items_repo.get_composed_meal_item_by_user_id_and_meal_id.return_value = None
#
#     new_meal = MagicMock()
#     new_meal.id = meal_id
#     new_meal.meal_type = MealType.BREAKFAST
#     new_meal.icon_id = existing_meal.icon_id
#     new_meal.calories = 350
#     new_meal.protein = 25
#     new_meal.carbs = 10
#     new_meal.fat = 15
#     new_meal.weight = 100
#     mock_meal_repository.update_meal_by_id.return_value = new_meal
#
#     mock_daily_summary_repository.add_custom_meal.return_value = mock_summary
#
#     result = await daily_summary_service.add_custom_meal(
#         user=user,
#         custom_meal=custom,
#     )
#
#     mock_daily_summary_repository.get_daily_summary.assert_awaited_once_with(user.id, today)
#     mock_meal_repository.update_meal_by_id.assert_awaited_once()
#     mock_daily_summary_repository.add_custom_meal.assert_awaited_once()
#
#     assert isinstance(result, MealInfo)


@pytest.mark.asyncio
async def test_add_meal_details_add_new(daily_summary_service, mock_meal_repository):
    meal_data = MealCreate(
        meal_name="Test_name",
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
        meal_name="Test_name",
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


@pytest.mark.asyncio
async def test_remove_meal_success(daily_summary_service, mock_daily_summary_repository):
    user = User(id=uuid.uuid4())
    day = date.today()
    meal_type = MealType.BREAKFAST
    meal_id = uuid.uuid4()

    daily_summary_obj = MockDailyMealsSummary()
    slot = daily_summary_obj.daily_meals[0]
    slot.status = MealStatus.TO_EAT
    slot.meal_type = meal_type

    mock_daily_summary_repository.get_daily_meals_summary.return_value = daily_summary_obj
    mock_daily_summary_repository.remove_meal_from_summary.return_value = True

    meal_request = RemoveMealRequest(day=day, meal_type=meal_type, meal_id=meal_id)

    result = await daily_summary_service.remove_meal_from_summary(user, meal_request)

    assert result.success is True
    assert result.day == day
    assert result.meal_type == meal_type
    assert result.meal_id == meal_id


@pytest.mark.asyncio
async def test_remove_meal_eaten_status(daily_summary_service, mock_daily_summary_repository, mock_meal_repository):
    user = User(id=uuid.uuid4())
    day = date.today()
    meal_type = MealType.BREAKFAST
    meal_id = uuid.uuid4()

    daily_summary_obj = MockDailyMealsSummary()
    slot = daily_summary_obj.daily_meals[0]
    slot.status = MealStatus.EATEN
    slot.meal_type = meal_type
    slot.meal_items = [MagicMock(meal_id=meal_id)]

    mock_daily_summary_repository.get_daily_meals_summary.return_value = daily_summary_obj
    mock_daily_summary_repository.remove_meal_from_summary.return_value = True

    mock_meal_repository.get_meal_calories_by_id.return_value = 500

    mock_meal_repository.get_meal_protein_by_id.return_value = 50
    mock_meal_repository.get_meal_fat_by_id.return_value = 20
    mock_meal_repository.get_meal_carbs_by_id.return_value = 100

    mock_daily_summary_repository.get_daily_macros_summary.return_value = MagicMock(
        calories=1000, protein=100, carbs=200, fat=50
    )
    mock_daily_summary_repository.update_daily_macros_summary.return_value = MagicMock()

    meal_request = RemoveMealRequest(day=day, meal_type=meal_type, meal_id=meal_id)

    result = await daily_summary_service.remove_meal_from_summary(user, meal_request)

    assert result.success is True
    mock_daily_summary_repository.update_daily_macros_summary.assert_awaited_once()


@pytest.mark.asyncio
async def test_remove_meal_no_plan_raises(daily_summary_service, mock_daily_summary_repository):
    user = User(id=uuid.uuid4())
    day = date.today()
    mock_daily_summary_repository.get_daily_meals_summary.return_value = None

    meal_request = RemoveMealRequest(day=day, meal_type=MealType.BREAKFAST, meal_id=uuid.uuid4())

    with pytest.raises(NotFoundInDatabaseException):
        await daily_summary_service.remove_meal_from_summary(user, meal_request)


@pytest.mark.asyncio
async def test_remove_meal_slot_not_found_raises(daily_summary_service, mock_daily_summary_repository):
    user = User(id=uuid.uuid4())
    day = date.today()
    meal_id = uuid.uuid4()

    daily_summary_obj = MockDailyMealsSummary()
    daily_summary_obj.daily_meals = []

    mock_daily_summary_repository.get_daily_meals_summary.return_value = daily_summary_obj

    meal_request = RemoveMealRequest(day=day, meal_type=MealType.BREAKFAST, meal_id=meal_id)

    with pytest.raises(NotFoundInDatabaseException):
        await daily_summary_service.remove_meal_from_summary(user, meal_request)


@pytest.mark.asyncio
async def test_remove_meal_not_removed_raises(daily_summary_service, mock_daily_summary_repository):
    user = User(id=uuid.uuid4())
    day = date.today()
    meal_id = uuid.uuid4()

    daily_summary_obj = MockDailyMealsSummary()
    slot = daily_summary_obj.daily_meals[0]
    slot.meal_type = MealType.BREAKFAST
    slot.status = MealStatus.TO_EAT

    mock_daily_summary_repository.get_daily_meals_summary.return_value = daily_summary_obj
    mock_daily_summary_repository.remove_meal_from_summary.return_value = False

    meal_request = RemoveMealRequest(day=day, meal_type=MealType.BREAKFAST, meal_id=meal_id)

    with pytest.raises(NotFoundInDatabaseException):
        await daily_summary_service.remove_meal_from_summary(user, meal_request)
