import pytest
from fastapi import HTTPException
from unittest.mock import MagicMock

from backend.users.user_repository import UserRepository
from backend.users.user_service import UserService
from backend.users.schemas import UserCreate, UserLogin, UserUpdate

user_create = UserCreate(
    name="test_name",
    last_name="test_last_name",
    age=19,
    country="Poland",
    email="test@example.com",
    password="password",
)


@pytest.fixture
def mock_user_repository():
    return MagicMock(spec=UserRepository)


@pytest.fixture
def user_service(mock_user_repository):
    return UserService(user_repository=mock_user_repository)


@pytest.mark.asyncio
async def test_register_user_existing(mock_user_repository, user_service):
    # Given
    mock_user_repository.get_user_by_email.return_value = MagicMock()

    # When
    with pytest.raises(HTTPException) as exc_info:
        await user_service.register(user_create)

    # Then
    assert exc_info.value.status_code == 400
    assert exc_info.value.detail == "User already exists"


@pytest.mark.asyncio
async def test_register_user_new(mock_user_repository, user_service):
    # Given
    mock_user_repository.get_user_by_email.return_value = None
    mock_user_repository.create_user.return_value = MagicMock(
        id=1, email="test@example.com"
    )

    # When
    new_user = await user_service.register(user_create)

    # Then
    assert new_user.email == "test@example.com"
    mock_user_repository.create_user.assert_called_once_with(user_create)


@pytest.mark.asyncio
async def test_login_user_not_found(mock_user_repository, user_service):
    # Given
    mock_user_repository.get_user_by_email.return_value = None
    user_login = UserLogin(email="test@example.com", password="password")

    # When
    with pytest.raises(HTTPException) as exc_info:
        await user_service.login(user_login)

    # Then
    assert exc_info.value.status_code == 400
    assert exc_info.value.detail == "Incorrect credentials"


@pytest.mark.asyncio
async def test_login_user_incorrect_password(mock_user_repository, user_service):
    # Given
    mock_user_repository.get_user_by_email.return_value = MagicMock(
        email="test@example.com", password="wrongpassword"
    )
    user_login = UserLogin(email="test@example.com", password="password")

    # When
    with pytest.raises(HTTPException) as exc_info:
        await user_service.login(user_login)

    # Then
    assert exc_info.value.status_code == 401
    assert exc_info.value.detail == "Incorrect password"


@pytest.mark.asyncio
async def test_login_user_success(mock_user_repository, user_service):
    # Given
    mock_user_repository.get_user_by_email.return_value = MagicMock(
        email="test@example.com", password="password"
    )
    user_login = UserLogin(email="test@example.com", password="password")

    # When
    logged_in_user = await user_service.login(user_login)

    # Then
    assert logged_in_user.email == "test@example.com"
    mock_user_repository.get_user_by_email.assert_called_once_with(user_login.email)


# Test logout_user
@pytest.mark.asyncio
async def test_logout_user_not_found(mock_user_repository, user_service):
    # Given
    mock_user_repository.get_user_by_id.return_value = None

    # When
    with pytest.raises(HTTPException) as exc_info:
        await user_service.logout(1)

    # Then
    assert exc_info.value.status_code == 404
    assert exc_info.value.detail == "User with this ID does not exist"


@pytest.mark.asyncio
async def test_logout_user_success(mock_user_repository, user_service):
    # Given
    mock_user_repository.get_user_by_id.return_value = MagicMock(id=1)

    # When
    response = await user_service.logout(1)

    # Then
    assert response.status_code == 200
    assert response.detail == "Logged out"


@pytest.mark.asyncio
async def test_update_user_not_found(mock_user_repository, user_service):
    # Given
    mock_user_repository.get_user_by_id.return_value = None
    user_update = UserUpdate(user_id=1, email="new@example.com")

    # When
    with pytest.raises(HTTPException) as exc_info:
        await user_service.update(user_update)

    # Then
    assert exc_info.value.status_code == 404
    assert exc_info.value.detail == "User with this ID does not exist"


@pytest.mark.asyncio
async def test_update_user_success(mock_user_repository, user_service):
    # Given
    mock_user_repository.get_user_by_id.return_value = MagicMock(id=1)
    mock_user_repository.update_user.return_value = MagicMock(
        id=1, email="new@example.com"
    )

    # When
    user_update = UserUpdate(user_id=1, email="new@example.com")
    updated_user = await user_service.update(user_update)

    # Then
    assert updated_user.email == "new@example.com"
    mock_user_repository.update_user.assert_called_once_with(
        user_update.user_id, user_update
    )


@pytest.mark.asyncio
async def test_delete_user_not_found(mock_user_repository, user_service):
    # Given
    mock_user_repository.get_user_by_id.return_value = None

    # When
    with pytest.raises(HTTPException) as exc_info:
        await user_service.delete(1)

    # Then
    assert exc_info.value.status_code == 404
    assert exc_info.value.detail == "User with this ID does not exist"


@pytest.mark.asyncio
async def test_delete_user_success(mock_user_repository, user_service):
    # Given
    mock_user_repository.get_user_by_id.return_value = MagicMock(id=1)
    mock_user_repository.delete_user.return_value = None

    # When
    response = await user_service.delete(1)

    # Then
    assert response is None
    mock_user_repository.delete_user.assert_called_once_with(1)
