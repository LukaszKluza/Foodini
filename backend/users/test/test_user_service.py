import pytest
import sys
from fastapi import HTTPException, status
from unittest.mock import MagicMock, AsyncMock, patch

from backend.users.schemas import UserCreate, UserLogin, UserUpdate
from backend.users.service.authorisation_service import AuthorizationService
from backend.users.service.password_service import PasswordService
from backend.mail import mail

with patch.dict(sys.modules, {"backend.users.user_repository": MagicMock()}):
    from backend.users.service.user_service import UserService


@pytest.fixture
def mock_hash_password():
    with patch.object(PasswordService, "hash_password", new_callable=AsyncMock) as mock:
        yield mock


@pytest.fixture
def mock_verify_password():
    with patch.object(
        PasswordService, "verify_password", new_callable=AsyncMock
    ) as mock:
        yield mock


@pytest.fixture
def mock_create_tokens():
    with patch.object(
        AuthorizationService, "create_tokens", new_callable=AsyncMock
    ) as mock:
        yield mock


@pytest.fixture
def mock_send_message():
    with patch.object(
        UserService, "send_verification_message", new_callable=AsyncMock
    ) as mock:
        yield mock


@pytest.fixture
def mock_create_verification_token():
    with patch.object(
        AuthorizationService, "create_url_safe_token", new_callable=AsyncMock
    ) as mock:
        yield mock


@pytest.fixture
def mock_mail_send():
    with patch.object(mail, "send_message", new_callable=AsyncMock) as mock:
        yield mock


@pytest.fixture
def mock_user_repository():
    repo = MagicMock()
    repo.get_user_by_email = AsyncMock()
    repo.create_user = AsyncMock()
    repo.get_user_by_id = AsyncMock()
    repo.update_user = AsyncMock()
    repo.delete_user = AsyncMock()
    return repo


@pytest.fixture
def user_service(mock_user_repository):
    return UserService(user_repository=mock_user_repository)


user_create = UserCreate(
    name="Testname",
    last_name="Testlastname",
    age=19,
    country="Poland",
    email="test@example.com",
    password="Password123",
)


@pytest.mark.asyncio
async def test_register_user_existing(mock_user_repository, user_service):
    # Given
    mock_user_repository.get_user_by_email.return_value = MagicMock()

    # When
    with pytest.raises(HTTPException) as exc_info:
        await user_service.register(user_create)

    # Then
    assert exc_info.value.status_code == status.HTTP_400_BAD_REQUEST
    assert exc_info.value.detail == "User already exists"


@pytest.mark.asyncio
async def test_register_user_new(
    mock_hash_password, mock_user_repository, mock_send_message, user_service
):
    # Given
    mock_user_repository.get_user_by_email.return_value = None
    mock_hash_password.return_value = "hashed_password"
    mock_user_repository.create_user.return_value = MagicMock(
        id=1, email="test@example.com"
    )
    mock_send_message.return_value = True

    # When
    new_user = await user_service.register(user_create)

    # Then
    assert new_user.email == "test@example.com"
    mock_user_repository.create_user.assert_called_once_with(user_create)
    mock_hash_password.assert_called_once_with("Password123")


@pytest.mark.asyncio
async def test_login_user_not_found(mock_user_repository, user_service):
    # Given
    mock_user_repository.get_user_by_email.return_value = None
    user_login = UserLogin(email="test@example.com", password="Password123")

    # When
    with pytest.raises(HTTPException) as exc_info:
        await user_service.login(user_login)

    # Then
    assert exc_info.value.status_code == status.HTTP_400_BAD_REQUEST
    assert exc_info.value.detail == "Incorrect credentials"


@pytest.mark.asyncio
async def test_login_user_incorrect_password(
    mock_verify_password, user_service, mock_user_repository
):
    # Given
    mock_user_repository.get_user_by_email.return_value = MagicMock(
        email="test@example.com", password="Wrongpassword123"
    )
    user_login = UserLogin(email="test@example.com", password="Password123")
    mock_verify_password.return_value = False

    # When
    with pytest.raises(HTTPException) as exc_info:
        await user_service.login(user_login)

    # Then
    assert exc_info.value.status_code == status.HTTP_403_FORBIDDEN
    assert exc_info.value.detail == "Incorrect password"
    mock_verify_password.assert_called_once_with("Password123", "Wrongpassword123")


@pytest.mark.asyncio
async def test_login_user_success(
    mock_verify_password, mock_create_tokens, mock_user_repository, user_service
):
    # Given
    mock_user_repository.get_user_by_email.return_value = MagicMock(
        id=1, email="test@example.com", password="Password123"
    )
    user_login = UserLogin(email="test@example.com", password="Password123")
    mock_verify_password.return_value = True
    mock_create_tokens.return_value = ("access_token", "refresh_token")

    # When
    logged_in_user = await user_service.login(user_login)

    # Then
    assert logged_in_user.email == "test@example.com"
    mock_user_repository.get_user_by_email.assert_called_once_with(user_login.email)
    mock_verify_password.assert_called_once_with("Password123", "Password123")
    mock_create_tokens.assert_called_once_with({"sub": user_login.email, "id": 1})


@pytest.mark.asyncio
async def test_logout_user_not_found(mock_user_repository, user_service):
    # Given
    mock_user_repository.get_user_by_id.return_value = None

    # When
    with pytest.raises(HTTPException) as exc_info:
        await user_service.logout(1)

    # Then
    assert exc_info.value.status_code == status.HTTP_404_NOT_FOUND
    assert exc_info.value.detail == "User with this ID does not exist"


@pytest.mark.asyncio
async def test_logout_user_success(mock_user_repository, user_service):
    # Given
    mock_user_repository.get_user_by_id.return_value = MagicMock(id=1)

    # When
    response = await user_service.logout(1)

    # Then
    assert response.status_code == status.HTTP_200_OK
    assert response.detail == "Logged out"


@pytest.mark.asyncio
async def test_update_user_not_found(mock_user_repository, user_service):
    # Given
    mock_user_repository.get_user_by_id.return_value = None
    user_update = UserUpdate(user_id=1, email="new@example.com")

    # When
    with pytest.raises(HTTPException) as exc_info:
        await user_service.update(1, 1, user_update)

    # Then
    assert exc_info.value.status_code == status.HTTP_404_NOT_FOUND
    assert exc_info.value.detail == "User with this ID does not exist"


@pytest.mark.asyncio
async def test_update_user_success(mock_user_repository, user_service):
    # Given
    mock_user_repository.get_user_by_id.return_value = MagicMock(id=1)
    mock_user_repository.update_user.return_value = MagicMock(
        id=1, email="new@example.com"
    )

    # When
    user_update = UserUpdate(country="Spain")
    updated_user = await user_service.update(1, 1, user_update)

    # Then
    assert updated_user.email == "new@example.com"
    mock_user_repository.update_user.assert_called_once_with(1, user_update)


@pytest.mark.asyncio
async def test_delete_user_not_found(mock_user_repository, user_service):
    # Given
    mock_user_repository.get_user_by_id.return_value = None

    # When
    with pytest.raises(HTTPException) as exc_info:
        await user_service.delete(1, 1)

    # Then
    assert exc_info.value.status_code == status.HTTP_404_NOT_FOUND
    assert exc_info.value.detail == "User with this ID does not exist"


@pytest.mark.asyncio
async def test_delete_user_success(mock_user_repository, user_service):
    # Given
    mock_user_repository.get_user_by_id.return_value = MagicMock(id=1)
    mock_user_repository.delete_user.return_value = None

    # When
    response = await user_service.delete(1, 1)

    # Then
    assert response is None
    mock_user_repository.delete_user.assert_called_once_with(1)


@pytest.mark.asyncio
async def test_send_verification_message_success(
    user_service, mock_user_repository, mock_create_verification_token, mock_mail_send
):
    # Given
    test_email = "test@example.com"
    mock_user = MagicMock(is_verified=False)
    mock_user_repository.get_user_by_email.return_value = mock_user
    mock_create_verification_token.return_value = "test_token"

    # When
    await user_service.send_verification_message(test_email)

    # Then
    mock_user_repository.get_user_by_email.assert_called_once_with(test_email)
    mock_create_verification_token.assert_called_once_with({"email": test_email})
    mock_mail_send.assert_called_once()

    args, _ = mock_mail_send.call_args
    sent_message = args[0]
    assert test_email in sent_message.recipients
    assert "test_token" in sent_message.body


@pytest.mark.asyncio
async def test_send_verification_message_user_not_exists(
    user_service, mock_user_repository
):
    # Given
    mock_user_repository.get_user_by_email.return_value = None

    # When/Then
    with pytest.raises(HTTPException) as exc:
        await user_service.send_verification_message("nonexistent@example.com")

    assert exc.value.status_code == 400
    assert "User does not exist" in exc.value.detail


@pytest.mark.asyncio
async def test_send_verification_message_already_verified(
    user_service, mock_user_repository
):
    # Given
    mock_user = MagicMock(is_verified=True)
    mock_user_repository.get_user_by_email.return_value = mock_user

    # When/Then
    with pytest.raises(HTTPException) as exc:
        await user_service.send_verification_message("verified@example.com")

    assert exc.value.status_code == 400
    assert "already verified" in exc.value.detail


@pytest.mark.asyncio
async def test_send_verification_message_email_failure(
    user_service, mock_user_repository, mock_mail_send
):
    # Given
    test_email = "test@example.com"
    mock_user = MagicMock(is_verified=False)
    mock_user_repository.get_user_by_email.return_value = mock_user

    mock_mail_send.side_effect = Exception("SMTP error")

    # When/Then
    with pytest.raises(HTTPException) as exc:
        await user_service.send_verification_message(test_email)

    assert exc.value.status_code == status.HTTP_500_INTERNAL_SERVER_ERROR
    assert "Failed to send verification email" in str(exc.value.detail)
