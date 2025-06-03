import pytest
from fastapi import HTTPException, status
from unittest.mock import AsyncMock

from backend.user_details.service.user_details_validation_service import (
    UserDetailsValidationService,
)
from backend.models import UserDetails


@pytest.mark.asyncio
async def test_ensure_user_details_exist_by_user_id():
    # Given
    mock_repo = AsyncMock()
    expected_user_details = UserDetails(
        id=1,
        user_id=1,
        height=180,
        weight=75,
        muscle_percentage=40.0,
        fat_percentage=18.0,
        water_percentage=50.0,
    )
    mock_repo.get_user_details_by_user_id.return_value = expected_user_details
    validator = UserDetailsValidationService(user_details_repository=mock_repo)

    # When
    result = await validator.ensure_user_details_exist_by_user_id(1)

    # Then
    assert result == expected_user_details
    mock_repo.get_user_details_by_user_id.assert_awaited_once_with(1)


@pytest.mark.asyncio
async def test_ensure_user_details_exist_by_user_id_failure():
    # Given
    mock_repo = AsyncMock()
    mock_repo.get_user_details_by_user_id.return_value = None
    validator = UserDetailsValidationService(user_details_repository=mock_repo)

    # When
    with pytest.raises(HTTPException) as exc_info:
        await validator.ensure_user_details_exist_by_user_id(1)

    # Then
    assert exc_info.value.status_code == status.HTTP_404_NOT_FOUND
    assert exc_info.value.detail == "User details not found"
    mock_repo.get_user_details_by_user_id.assert_awaited_once_with(1)
