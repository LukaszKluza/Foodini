import sys
from datetime import date
from unittest.mock import AsyncMock, MagicMock, patch

import pytest

from backend.core.not_found_in_database_exception import NotFoundInDatabaseException
from backend.models import User, UserDetails
from backend.user_details import enums
from backend.user_details.schemas import UserDetailsCreate, UserDetailsUpdate
from backend.user_details.service.user_details_validation_service import (
    UserDetailsValidationService,
)

with patch.dict(sys.modules, {"backend.user_details.user_details_repository": MagicMock()}):
    from backend.user_details.service.user_details_service import UserDetailsService


@pytest.fixture
def mock_user_details_repository():
    repo = AsyncMock()
    repo.add_user_details = AsyncMock()
    repo.get_user_details_by_id = AsyncMock()
    repo.update_user_details = AsyncMock()
    return repo


@pytest.fixture
def mock_user_gateway():
    gateway = MagicMock()
    gateway.ensure_user_exists_by_email = AsyncMock()
    gateway.ensure_user_exists_by_id = AsyncMock()
    return gateway


@pytest.fixture
def user_details_service(mock_user_details_repository, mock_user_gateway):
    return UserDetailsService(
        user_details_repository=mock_user_details_repository,
        user_gateway=mock_user_gateway,
        user_details_validators=UserDetailsValidationService(mock_user_details_repository),
    )


basic_user_details = UserDetails(
    id=1,
    user_id=1,
    gender_id=1,
    height_cm=180.0,
    weight_kg=75.0,
    date_of_birth=date(2002, 5, 15),
    diet_type_id=4,
    dietary_restrictions=[enums.DietaryRestriction.LACTOSE],
    diet_goal_kg=70.0,
    meals_per_day=3,
    diet_intensity_id=2,
    activity_level_id=3,
    stress_level_id=3,
    sleep_quality_id=3,
    muscle_percentage=45.0,
    water_percentage=55.0,
    fat_percentage=18.0,
)

updated_user_details = UserDetails(
    id=1,
    user_id=1,
    gender_id=1,
    height_cm=180.0,
    weight_kg=75.0,
    date_of_birth=date(2002, 5, 15),
    diet_type_id=4,
    dietary_restrictions=[enums.DietaryRestriction.LACTOSE],
    diet_goal_kg=70.0,
    meals_per_day=3,
    diet_intensity_id=2,
    activity_level_id=3,
    stress_level_id=3,
    sleep_quality_id=3,
    muscle_percentage=48.0,
    water_percentage=58.0,
    fat_percentage=16.0,
)

user_details_create = UserDetailsCreate(
    gender=enums.Gender.MALE,
    height_cm=180.0,
    weight_kg=75.0,
    date_of_birth=date(2002, 5, 15),
    diet_type=enums.DietType.FAT_LOSS,
    dietary_restrictions=[enums.DietaryRestriction.LACTOSE],
    diet_goal_kg=70.0,
    meals_per_day=3,
    diet_intensity=enums.DietIntensity.NORMAL,
    activity_level=enums.ActivityLevel.ACTIVE,
    stress_level=enums.StressLevel.HIGH,
    sleep_quality=enums.SleepQuality.GOOD,
    muscle_percentage=30.0,
    water_percentage=50.0,
    fat_percentage=15.0,
)

user_details_update = UserDetailsUpdate(
    muscle_percentage=32.0,
    water_percentage=52.0,
    fat_percentage=13.0,
)

basic_user = User(
    id=1,
    email="test@example.com",
)


@pytest.mark.asyncio
async def test_get_user_details_when_user_exist(
    user_details_service,
    mock_user_details_repository,
    mock_user_gateway,
):
    # Given
    mock_user_gateway.ensure_user_exists_by_id.return_value = basic_user
    mock_user_gateway.check_user_permission.return_value = None
    mock_user_details_repository.get_user_details_by_user_id.return_value = basic_user_details

    # When
    response = await user_details_service.get_user_details_by_user(basic_user)

    # Then
    assert response == basic_user_details


@pytest.mark.asyncio
async def test_add_user_details_when_details_not_exist(
    user_details_service,
    mock_user_details_repository,
    mock_user_gateway,
):
    # Given
    mock_user_gateway.ensure_user_exists_by_id.return_value = basic_user
    mock_user_details_repository.get_user_details_by_user_id.side_effect = NotFoundInDatabaseException("User not found")
    mock_user_details_repository.add_user_details = AsyncMock(return_value=basic_user_details)

    # When
    response = await user_details_service.add_user_details(user_details_create, basic_user)

    # Then
    assert response == basic_user_details
    mock_user_details_repository.add_user_details.assert_called_once()
    mock_user_details_repository.update_user_details.assert_not_called()


@pytest.mark.asyncio
async def test_add_user_details_when_details_exist(
    user_details_service,
    mock_user_details_repository,
    mock_user_gateway,
):
    # Given
    mock_user_gateway.ensure_user_exists_by_id.return_value = basic_user
    mock_user_details_repository.update_user_details_by_user_id.return_value = basic_user_details
    mock_user_details_repository.get_user_details_by_id.return_value = basic_user_details

    # When
    response = await user_details_service.add_user_details(user_details_create, basic_user)

    # Then
    assert response == basic_user_details
    mock_user_details_repository.add_user_details.assert_not_called()
    mock_user_details_repository.update_user_details_by_user_id.assert_called_once()


@pytest.mark.asyncio
async def test_update_user_details_when_details_exist(
    user_details_service,
    mock_user_details_repository,
    mock_user_gateway,
):
    # Given
    mock_user_gateway.ensure_user_exists_by_id.return_value = basic_user
    mock_user_details_repository.get_user_details_by_user_id.return_value = basic_user_details
    mock_user_details_repository.update_user_details_by_user_id.return_value = updated_user_details

    # When
    result = await user_details_service.update_user_details(user_details_update, basic_user)

    # Then
    assert result == updated_user_details
    mock_user_details_repository.update_user_details_by_user_id.assert_called_once_with(1, user_details_update)


@pytest.mark.asyncio
async def test_update_user_details_when_details_not_exist(
    user_details_service,
    mock_user_details_repository,
    mock_user_gateway,
):
    # Given
    mock_user_gateway.ensure_user_exists_by_id.return_value = basic_user
    mock_user_details_repository.get_user_details_by_user_id.side_effect = NotFoundInDatabaseException("User not found")

    # When
    with pytest.raises(NotFoundInDatabaseException) as exc_info:
        await user_details_service.update_user_details(user_details_update, basic_user)

    # Then
    assert exc_info.value.detail == "User not found"
