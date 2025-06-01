import sys
from datetime import date
from unittest.mock import patch, MagicMock, AsyncMock

import pytest
from fastapi import HTTPException, status

from backend.models import UserDetails, User
from backend.user_details import enums
from backend.user_details.schemas import UserDetailsCreate, UserDetailsUpdate

with patch.dict(
    sys.modules, {"backend.user_details.user_details_repository": MagicMock()}
):
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
def mock_user_details_validators():
    validators = MagicMock()
    validators.ensure_user_details_exist_by_user_id = AsyncMock()
    return validators


@pytest.fixture
def user_details_service(
    mock_user_details_repository, mock_user_gateway, mock_user_details_validators
):
    return UserDetailsService(
        user_details_repository=mock_user_details_repository,
        user_gateway=mock_user_gateway,
        user_details_validators=mock_user_details_validators,
    )


basic_user_details = UserDetails(
    id=1,
    user_id=1,
    gender_id=1,
    height_cm=180.0,
    weight_kg=75.0,
    date_of_birth=date(2002, 5, 15),
    diet_type_id=4,
    allergies=[enums.Allergies.LACTOSE],
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
    allergies=[enums.Allergies.LACTOSE],
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
    diet_type=enums.DietType.VEGETARIAN,
    allergies=[enums.Allergies.LACTOSE],
    diet_goal_kg=70.0,
    meals_per_day=3,
    diet_intensity=enums.DietIntensity.NORMAL,
    activity_level=enums.ActivityLevel.ACTIVE,
    stress_level=enums.StressLevel.HIGH,
    sleep_quality=enums.SleepQuality.GOOD,
    muscle_percentage=45.0,
    water_percentage=55.0,
    fat_percentage=18.0,
)

user_details_update = UserDetailsUpdate(
    muscle_percentage=48.0,
    water_percentage=58.0,
    fat_percentage=16.0,
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
    mock_user_details_validators,
):
    # Given
    token_payload = {"id": "1"}
    mock_user_gateway.ensure_user_exists_by_id.return_value = basic_user
    mock_user_gateway.check_user_permission.return_value = None
    mock_user_details_repository.get_user_details_by_user_id.return_value = (
        basic_user_details
    )

    # When
    response = await user_details_service.get_user_details_by_user_id(token_payload, 1)

    # Then
    assert response == basic_user_details


@pytest.mark.asyncio
async def test_get_user_details_when_not_exist(
    user_details_service,
    mock_user_details_repository,
    mock_user_gateway,
):
    # Given
    token_payload = {"id": "1"}
    mock_user_gateway.ensure_user_exists_by_id.side_effect = HTTPException(
        status_code=status.HTTP_400_BAD_REQUEST, detail="User does not exist"
    )
    mock_user_details_repository.get_user_details_by_id.return_value = (
        basic_user_details
    )

    # When
    with pytest.raises(HTTPException) as exc_info:
        await user_details_service.get_user_details_by_user_id(token_payload, 1)

    # Then
    assert exc_info.value.status_code == status.HTTP_400_BAD_REQUEST
    assert exc_info.value.detail == "User does not exist"


@pytest.mark.asyncio
async def test_add_user_details_when_details_not_exist(
    user_details_service,
    mock_user_details_repository,
    mock_user_gateway,
    mock_user_details_validators,
):
    # Given
    token_payload = {"id": "1"}
    mock_user_gateway.ensure_user_exists_by_id.return_value = basic_user
    mock_user_details_validators.ensure_user_details_exist_by_user_id.return_value = (
        None
    )
    mock_user_details_repository.add_user_details = AsyncMock(
        return_value=basic_user_details
    )
    user_details_service.get_user_details_by_user_id = AsyncMock(
        side_effect=HTTPException(status_code=404, detail="Not found")
    )

    # When
    response = await user_details_service.add_user_details(
        token_payload, user_details_create, 1
    )

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
    token_payload = {"id": "1"}
    mock_user_gateway.ensure_user_exists_by_id.return_value = basic_user
    mock_user_details_repository.update_user_details.return_value = basic_user_details
    mock_user_details_repository.get_user_details_by_id.return_value = (
        basic_user_details
    )

    # When
    response = await user_details_service.add_user_details(
        token_payload, user_details_create, 1
    )

    # Then
    assert response == basic_user_details
    mock_user_details_repository.add_user_details.assert_not_called()
    mock_user_details_repository.update_user_details.assert_called_once()


@pytest.mark.asyncio
async def test_update_user_details_when_not_exist(
    user_details_service,
    mock_user_details_repository,
    mock_user_gateway,
):
    # Given
    token_payload = {"id": "1"}
    mock_user_gateway.ensure_user_exists_by_id.return_value = basic_user
    mock_user_details_repository.get_user_details_by_id.return_value = None

    # When
    with pytest.raises(HTTPException) as exc_info:
        await user_details_service.update_user_details(
            token_payload, user_details_update, 1
        )

    # Then
    assert exc_info.value.status_code == status.HTTP_400_BAD_REQUEST
    assert exc_info.value.detail == "User details do not exist"
    mock_user_details_repository.update_user_details.assert_not_called()


@pytest.mark.asyncio
async def test_update_user_details_when_not_exist(
    user_details_service,
    mock_user_details_repository,
    mock_user_gateway,
    mock_user_details_validators,
):
    # Given
    token_payload = {"id": "1"}
    mock_user_gateway.ensure_user_exists_by_id.return_value = basic_user

    # Tu mockujemy metodę, która rzuca wyjątek
    mock_user_details_validators.ensure_user_details_exist_by_user_id.side_effect = (
        HTTPException(status_code=404, detail="User details not found")
    )

    # When / Then
    with pytest.raises(HTTPException) as exc_info:
        await user_details_service.update_user_details(
            token_payload, user_details_update, 1
        )

    assert exc_info.value.status_code == 404
    assert exc_info.value.detail == "User details not found"
