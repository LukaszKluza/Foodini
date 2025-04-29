import pytest
from fastapi import HTTPException, status
from datetime import datetime, timedelta
from unittest.mock import AsyncMock, MagicMock

from backend.settings import config
from backend.users.service.user_validation_service import UserValidationService


@pytest.fixture
def mock_user_repository():
    repo = MagicMock()
    repo.get_user_by_email = AsyncMock()
    repo.create_user = AsyncMock()
    repo.get_user_by_id = AsyncMock()
    repo.update_password = AsyncMock()
    repo.update_user = AsyncMock()
    repo.delete_user = AsyncMock()
    repo.verify_user = AsyncMock()
    return repo


@pytest.fixture
def user_validators(mock_user_repository):
    return UserValidationService(user_repository=mock_user_repository)


@pytest.mark.asyncio
async def test_ensure_verified_user_success(user_validators):
    # Given
    mock_user = MagicMock()
    mock_user.is_verified = True

    # When
    result = user_validators.ensure_verified_user(mock_user)

    # Then
    assert result == mock_user


@pytest.mark.asyncio
async def test_ensure_verified_user_failure(user_validators):
    # Given
    mock_user = MagicMock()
    mock_user.is_verified = False

    # When/Then
    with pytest.raises(HTTPException) as exc_info:
        user_validators.ensure_verified_user(mock_user)

    assert exc_info.value.status_code == status.HTTP_403_FORBIDDEN
    assert "Account not verified" in exc_info.value.detail


@pytest.mark.asyncio
async def test_check_user_permission_success(user_validators):
    # When
    user_validators.check_user_permission(1, 1)


@pytest.mark.asyncio
async def test_check_user_permission_failure(user_validators):
    # When/Then
    with pytest.raises(HTTPException) as exc_info:
        user_validators.check_user_permission(1, 2)

    assert exc_info.value.status_code == status.HTTP_403_FORBIDDEN
    assert "Invalid token" in exc_info.value.detail


@pytest.mark.asyncio
async def test_check_last_password_change_data_time_success(user_validators):
    # Given
    mock_user = MagicMock()
    mock_user.last_password_update = datetime.now(config.TIMEZONE) - timedelta(days=2)

    # When
    user_validators.check_last_password_change_data_time(mock_user)


@pytest.mark.asyncio
async def test_check_last_password_change_data_time_failure(user_validators):
    # Given
    mock_user = MagicMock()
    mock_user.last_password_update = datetime.now(config.TIMEZONE) - timedelta(hours=12)

    # When/Then
    with pytest.raises(HTTPException) as exc_info:
        user_validators.check_last_password_change_data_time(mock_user)

    assert exc_info.value.status_code == status.HTTP_403_FORBIDDEN
    assert "wait at least 1 day" in exc_info.value.detail

    assert str(mock_user.last_password_update.year) in exc_info.value.detail


@pytest.mark.asyncio
async def test_ensure_user_exists_by_email_success(
    user_validators, mock_user_repository
):
    # Given
    mock_user = MagicMock()
    mock_user_repository.get_user_by_email = AsyncMock(return_value=mock_user)

    # When
    result = await user_validators.ensure_user_exists_by_email("test@example.com")

    # Then
    assert result == mock_user
    mock_user_repository.get_user_by_email.assert_called_once_with("test@example.com")


@pytest.mark.asyncio
async def test_ensure_user_exists_by_email_failure(
    user_validators, mock_user_repository
):
    # Given
    mock_user_repository.get_user_by_email = AsyncMock(return_value=None)

    # When/Then
    with pytest.raises(HTTPException) as exc_info:
        await user_validators.ensure_user_exists_by_email("test@example.com")

    assert exc_info.value.status_code == status.HTTP_400_BAD_REQUEST
    assert "User does not exist" in exc_info.value.detail
    mock_user_repository.get_user_by_email.assert_called_once_with("test@example.com")


@pytest.mark.asyncio
async def test_ensure_user_exists_by_id_success(user_validators, mock_user_repository):
    # Given
    mock_user = MagicMock()
    mock_user_repository.get_user_by_id = AsyncMock(return_value=mock_user)

    # When
    result = await user_validators.ensure_user_exists_by_id(1)

    # Then
    assert result == mock_user
    mock_user_repository.get_user_by_id.assert_called_once_with(1)


@pytest.mark.asyncio
async def test_ensure_user_exists_by_id_failure(user_validators, mock_user_repository):
    # Given
    mock_user_repository.get_user_by_id = AsyncMock(return_value=None)

    # When/Then
    with pytest.raises(HTTPException) as exc_info:
        await user_validators.ensure_user_exists_by_id(1)

    assert exc_info.value.status_code == status.HTTP_400_BAD_REQUEST
    assert "User does not exist" in exc_info.value.detail
    mock_user_repository.get_user_by_id.assert_called_once_with(1)
