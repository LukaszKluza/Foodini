import pytest
import sys
from datetime import datetime, timedelta
from fastapi import HTTPException, status
from fastapi_mail.errors import ConnectionErrors
from unittest.mock import MagicMock, AsyncMock, patch
from backend.mail import MailService
from backend.users.schemas import (
    UserCreate,
    UserLogin,
    UserUpdate,
    PasswordResetRequest,
    NewPasswordConfirm,
)
from backend.users.service.authorisation_service import AuthorizationService
from backend.users.service.password_service import PasswordService
from backend.settings import config

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
def mock_delete_user_token():
    with patch.object(
        AuthorizationService, "delete_user_token", new_callable=AsyncMock
    ) as mock:
        yield mock


@pytest.fixture
def mock_create_url_safe_token():
    with patch.object(
        AuthorizationService, "create_url_safe_token", new_callable=AsyncMock
    ) as mock:
        yield mock


@pytest.fixture
def mock_decode_url_safe_token():
    with patch.object(
        AuthorizationService, "decode_url_safe_token", new_callable=AsyncMock
    ) as mock:
        yield mock


@pytest.fixture
def mock_create_message():
    with patch.object(MailService, "create_message", new_callable=AsyncMock) as mock:
        yield mock


@pytest.fixture
def mock_send_message():
    with patch.object(MailService, "send_message", new_callable=AsyncMock) as mock:
        yield mock


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
    mock_hash_password,
    mock_user_repository,
    mock_send_message,
    mock_create_url_safe_token,
    mock_create_message,
    user_service,
):
    # Given
    mock_user_repository.get_user_by_email.return_value = None
    mock_hash_password.return_value = "hashed_password"
    mock_user_repository.create_user.return_value = MagicMock(
        id=1, email="test@example.com"
    )
    mock_create_url_safe_token.return_value = "url_safe_token"
    mock_create_message.return_value = "message"
    mock_send_message.return_value = True

    # When
    new_user = await user_service.register(user_create)

    # Then
    assert new_user.email == "test@example.com"
    mock_user_repository.create_user.assert_called_once_with(user_create)
    mock_hash_password.assert_called_once_with("Password123")
    mock_send_message.assert_called_once_with("message")


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
    assert exc_info.value.detail == "User does not exist"


@pytest.mark.asyncio
async def test_login_user_incorrect_password(
    mock_verify_password, mock_user_repository, user_service
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
    assert exc_info.value.status_code == status.HTTP_400_BAD_REQUEST
    assert exc_info.value.detail == "User does not exist"


@pytest.mark.asyncio
async def test_logout_user_success(
    mock_user_repository, mock_delete_user_token, user_service
):
    # Given
    mock_user_repository.get_user_by_id.return_value = MagicMock(id=1)
    mock_user_repository.get_user_by_email.return_value = MagicMock(id=1)

    # When
    response = await user_service.logout(1)

    # Then
    assert response.status_code == status.HTTP_200_OK
    assert response.detail == "Logged out"
    mock_delete_user_token.assert_called_once_with(1)


@pytest.mark.asyncio
async def test_reset_password_user_unlogged(
    mock_user_repository,
    mock_create_url_safe_token,
    mock_create_message,
    mock_send_message,
    user_service,
):
    # Given
    mock_user_repository.get_user_by_email.return_value = MagicMock(
        id=1, last_password_update=datetime.now(config.TIMEZONE) - timedelta(days=2)
    )
    password_reset_request = PasswordResetRequest(id=None, email="test@example.com")
    mock_create_url_safe_token.return_value = "token_url"
    mock_create_message.return_value = "message"
    mock_send_message.return_value = True

    # When
    await user_service.reset_password(password_reset_request, "form_url")

    # Then
    mock_send_message.assert_called_once_with("message")


@pytest.mark.asyncio
async def test_reset_password_user_logged_successful(
    mock_user_repository,
    mock_delete_user_token,
    mock_create_url_safe_token,
    mock_create_message,
    mock_send_message,
    user_service,
):
    # Given
    mock_user_repository.get_user_by_email.return_value = MagicMock(
        id=1, last_password_update=datetime.now(config.TIMEZONE) - timedelta(days=2)
    )
    mock_user_repository.update_password.return_value = MagicMock(
        id=1, email="test@example.com"
    )
    mock_delete_user_token.return_value = MagicMock(1)
    password_reset_request = PasswordResetRequest(id=1, email="test@example.com")
    mock_create_url_safe_token.return_value = "token_url"
    mock_create_message.return_value = "message"
    mock_send_message.return_value = True

    # When
    await user_service.reset_password(password_reset_request, "form_url")

    # Then
    mock_send_message.assert_called_once_with("message")
    mock_delete_user_token.assert_called_once_with(1)


@pytest.mark.asyncio
async def test_reset_password_user_logged_too_fast(
    mock_user_repository,
    mock_delete_user_token,
    mock_create_url_safe_token,
    mock_create_message,
    mock_send_message,
    user_service,
):
    # Given
    last_password_update = datetime.now(config.TIMEZONE) - timedelta(hours=2)
    mock_user_repository.get_user_by_email.return_value = MagicMock(
        id=1, last_password_update=last_password_update
    )
    mock_user_repository.update_password.return_value = MagicMock(
        id=1, email="test@example.com"
    )
    mock_delete_user_token.return_value = MagicMock(1)
    password_reset_request = PasswordResetRequest(id=1, email="test@example.com")
    mock_create_url_safe_token.return_value = "token_url"
    mock_create_message.return_value = "message"
    mock_send_message.return_value = True

    # When
    with pytest.raises(HTTPException) as exc_info:
        await user_service.reset_password(password_reset_request, "form_url")

    # Then
    assert exc_info.value.status_code == status.HTTP_403_FORBIDDEN
    assert (
        exc_info.value.detail
        == f"You must wait at least 1 day before changing your password again, last changed {last_password_update}"
    )


@pytest.mark.asyncio
async def test_update_user_not_found(mock_user_repository, user_service):
    # Given
    mock_user_repository.get_user_by_id.return_value = None
    user_update = UserUpdate(email="new@example.com")

    # When
    with pytest.raises(HTTPException) as exc_info:
        await user_service.update(1, 1, user_update)

    # Then
    assert exc_info.value.status_code == status.HTTP_400_BAD_REQUEST
    assert exc_info.value.detail == "User does not exist"


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
    assert exc_info.value.status_code == status.HTTP_400_BAD_REQUEST
    assert exc_info.value.detail == "User does not exist"


@pytest.mark.asyncio
async def test_delete_user_success(
    mock_user_repository, mock_delete_user_token, user_service
):
    # Given
    mock_user_repository.get_user_by_id.return_value = MagicMock(id=1)
    mock_user_repository.delete_user.return_value = None
    mock_delete_user_token.return_value = MagicMock(1)

    # When
    response = await user_service.delete(1, 1)

    # Then
    assert response is None
    mock_user_repository.delete_user.assert_called_once_with(1)


@pytest.mark.asyncio
async def test_process_new_account_verification_message_success(
    user_service,
    mock_user_repository,
    mock_send_message,
):
    # Given
    test_email = "test@example.com"
    test_token = "test_token"
    mock_user = MagicMock(is_verified=False)
    mock_user_repository.get_user_by_email.return_value = mock_user
    mock_create_url_safe_token.return_value = test_token

    # When
    await user_service.process_new_account_verification_message(test_email, test_token)

    # Then
    mock_user_repository.get_user_by_email.assert_called_once_with(test_email)
    mock_send_message.assert_called_once()

    args, _ = mock_send_message.call_args
    sent_message = args[0]
    assert test_email in sent_message.recipients
    assert "test_token" in sent_message.body


@pytest.mark.asyncio
async def test_process_new_account_verification_message_already_verified(
    user_service, mock_user_repository
):
    # Given
    mock_user = MagicMock(is_verified=True)
    mock_user_repository.get_user_by_email.return_value = mock_user

    # When/Then
    with pytest.raises(HTTPException) as exc:
        await user_service.process_new_account_verification_message(
            "verified@example.com", "test_token"
        )

    assert exc.value.status_code == 400
    assert "already verified" in exc.value.detail


@pytest.mark.asyncio
async def test_confirm_new_password(
    mock_user_repository,
    mock_hash_password,
    mock_decode_url_safe_token,
    user_service,
):
    # Given
    token = "test_token"
    new_password_confirm = NewPasswordConfirm(
        email="test@example.com", password="New_password_1"
    )

    mock_user_repository.get_user_by_email.return_value = MagicMock(
        id=1, email="test@example.com"
    )
    mock_hash_password.return_value = "hashed_password"
    mock_decode_url_safe_token.return_value = {"email": "test@example.com", "id": 1}
    mock_user_repository.update_password.return_value = MagicMock(
        id=1, email="test@example.com"
    )

    # When
    await user_service.confirm_new_password(token, new_password_confirm)

    # Then
    mock_hash_password.assert_called_once_with("New_password_1")
    mock_user_repository.update_password.assert_called_once_with(
        1, "hashed_password", datetime.now(config.TIMEZONE)
    )


@pytest.mark.asyncio
async def test_confirm_new_account(
    mock_user_repository,
    mock_hash_password,
    mock_decode_url_safe_token,
    user_service,
):
    # Given
    token = "test_token"

    mock_user_repository.get_user_by_email.return_value = MagicMock(
        id=1, email="test@example.com"
    )
    mock_decode_url_safe_token.return_value = {"email": "test@example.com", "id": 1}
    mock_user_repository.verify_user.return_value = MagicMock(
        id=1, email="test@example.com"
    )

    # When
    await user_service.confirm_new_account(token)

    # Then
    mock_user_repository.verify_user.assert_called_once_with("test@example.com")


@pytest.mark.asyncio
async def test_resend_verification(
    mock_hash_password,
    mock_user_repository,
    mock_send_message,
    mock_create_url_safe_token,
    mock_create_message,
    user_service,
):
    # Given
    mock_user_repository.get_user_by_email.return_value = MagicMock(
        id=1, email="test@example.com", is_verified=False
    )
    mock_create_url_safe_token.return_value = "url_safe_token"
    mock_create_message.return_value = "message"
    mock_send_message.return_value = True

    # When
    await user_service.resend_verification("test@example.com")

    # Then
    mock_send_message.assert_called_once_with("message")
