import pytest
import sys
from datetime import datetime, timedelta
from fastapi import HTTPException, status
from unittest.mock import MagicMock, AsyncMock, ANY, patch

from backend.mail import MailService
from backend.users.schemas import (
    UserCreate,
    UserLogin,
    UserUpdate,
    PasswordResetRequest,
    NewPasswordConfirm,
)
from backend.users.service.user_authorisation_service import AuthorizationService
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
def mock_auth_service():
    # Najpierw mockujemy Redis, ponieważ AuthorizationService go używa
    with patch("backend.core.database.get_redis") as mock_redis:
        mock_redis.return_value = AsyncMock()  # Mockowane połączenie Redis

        # Teraz mockujemy całą klasę AuthorizationService
        with patch(
            "backend.users.service.user_authorisation_service.AuthorizationService"
        ) as mock:
            # Konfigurujemy mockowane metody
            mock.create_tokens = AsyncMock(
                return_value=("access_token", "refresh_token")
            )
            mock.delete_user_token = AsyncMock(return_value=True)
            mock.create_url_safe_token = AsyncMock(return_value="url_safe_token")
            mock.decode_url_safe_token = AsyncMock(return_value={"user_id": 1})
            mock.verify_token = AsyncMock(
                return_value={"id": 1, "email": "test@example.com"}
            )
            mock.get_payload_from_token = AsyncMock(return_value={"id": 1})
            mock.refresh_access_token = AsyncMock(return_value="new_access_token")

            yield mock


@pytest.fixture
def mock_email_verification_service():
    mock = MagicMock()
    mock.process_new_account_verification = AsyncMock()
    mock.process_password_reset_verification = AsyncMock()
    return mock


@pytest.fixture
def mock_user_validators():
    mock = MagicMock()
    mock.ensure_user_exists_by_email = AsyncMock()
    mock.ensure_verified_user = AsyncMock()
    mock.check_user_permission = AsyncMock()
    mock.check_last_password_change_data_time = AsyncMock()
    mock.ensure_user_exists_by_id = AsyncMock()
    return mock


@pytest.fixture
def user_service(
    mock_user_repository, mock_email_verification_service, mock_user_validators
):
    return UserService(
        user_repository=mock_user_repository,
        email_verification_service=mock_email_verification_service,
        user_validators=mock_user_validators,
    )


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
    mock_email_verification_service,
    user_service,
):
    # Given
    mock_user_repository.get_user_by_email.return_value = None
    mock_hash_password.return_value = "hashed_password"
    mock_user_repository.create_user.return_value = MagicMock(
        id=1, email="test@example.com"
    )

    # When
    new_user = await user_service.register(user_create)

    # Then
    assert new_user.email == "test@example.com"
    mock_email_verification_service.process_new_account_verification.assert_called_once()


@pytest.mark.asyncio
async def test_login_user_not_found(user_service, mock_user_validators):
    # Given
    user_login = UserLogin(email="test@example.com", password="Password123")
    mock_user_validators.ensure_user_exists_by_email.side_effect = HTTPException(
        status_code=status.HTTP_400_BAD_REQUEST, detail="User does not exist"
    )

    # When/Then
    with pytest.raises(HTTPException) as exc_info:
        await user_service.login(user_login)
    assert exc_info.value.status_code == status.HTTP_400_BAD_REQUEST


@pytest.mark.asyncio
async def test_login_user_incorrect_password(
    mock_verify_password, mock_user_validators, user_service
):
    # Given
    mock_user = MagicMock(password="hashed_password")
    mock_user_validators.ensure_user_exists_by_email.return_value = mock_user
    mock_verify_password.return_value = False
    user_login = UserLogin(email="test@example.com", password="Password123")

    # When
    with pytest.raises(HTTPException) as exc_info:
        await user_service.login(user_login)

    # Then
    assert exc_info.value.status_code == status.HTTP_403_FORBIDDEN
    mock_verify_password.assert_called_once_with("Password123", "hashed_password")


@pytest.mark.asyncio
async def test_login_user_success(
    mock_verify_password,
    mock_create_tokens,
    mock_user_validators,
    user_service,
):
    # Given
    mock_user = MagicMock(id=1, email="test@example.com", password="hashed_password")
    mock_user_validators.ensure_user_exists_by_email.return_value = mock_user
    mock_verify_password.return_value = True
    mock_create_tokens.return_value = ("access_token", "refresh_token")
    user_login = UserLogin(email="test@example.com", password="Password123")

    # When
    result = await user_service.login(user_login)

    # Then
    assert result.email == "test@example.com"
    assert result.access_token == "access_token"


@pytest.mark.asyncio
async def test_logout_user_not_found(mock_user_validators, user_service):
    # Given
    mock_user_validators.ensure_user_exists_by_id.side_effect = HTTPException(
        status_code=status.HTTP_400_BAD_REQUEST, detail="User does not exist"
    )

    # When
    with pytest.raises(HTTPException) as exc_info:
        await user_service.logout(MagicMock(), 1)

    # Then
    assert exc_info.value.status_code == status.HTTP_400_BAD_REQUEST


@pytest.mark.asyncio
async def test_logout_user_success(
    mock_user_validators, mock_delete_user_token, user_service
):
    mock_user_validators.ensure_user_exists_by_id.return_value = MagicMock(id=1)

    response = await user_service.logout(MagicMock(), 1)

    assert response.status_code == status.HTTP_200_OK
    mock_delete_user_token.assert_called_once_with(1)


@pytest.mark.asyncio
async def test_reset_password_user_unlogged(
    mock_user_validators,
    mock_email_verification_service,
    user_service,
    mock_create_url_safe_token,
):
    # Given
    mock_user = MagicMock(
        id=1,
        email="test@example.com",
        last_password_update=datetime.now(config.TIMEZONE) - timedelta(days=2),
    )
    mock_user_validators.ensure_user_exists_by_email.return_value = mock_user
    mock_create_url_safe_token.return_value = "test_token"

    # When
    await user_service.reset_password(
        PasswordResetRequest(email="test@example.com"), "form_url"
    )

    # Then
    mock_email_verification_service.process_password_reset_verification.assert_called_once()


@pytest.mark.asyncio
async def test_reset_password_user_logged_successful(
    mock_user_validators,
    mock_email_verification_service,
    user_service,
    mock_delete_user_token,
):
    # Given
    mock_user = MagicMock(
        id=1,
        email="test@example.com",
        last_password_update=datetime.now(config.TIMEZONE) - timedelta(days=2),
    )
    mock_user_validators.ensure_user_exists_by_email.return_value = mock_user

    with patch.object(
        AuthorizationService, "verify_token", new_callable=AsyncMock
    ) as mock_verify:
        mock_verify.return_value = {"id": 1}
        mock_delete_user_token.return_value = True

        await user_service.reset_password(
            PasswordResetRequest(email="test@example.com", token="valid_token"),
            "form_url",
        )

        mock_email_verification_service.process_password_reset_verification.assert_called_once()


@pytest.mark.asyncio
async def test_reset_password_user_logged_too_fast(mock_user_validators, user_service):
    last_update = datetime.now(config.TIMEZONE) - timedelta(hours=2)
    mock_user = MagicMock(id=1, last_password_update=last_update)
    mock_user_validators.ensure_user_exists_by_email.return_value = mock_user
    mock_user_validators.check_last_password_change_data_time.side_effect = (
        HTTPException(
            status_code=403,
            detail="You must wait at least 1 day before changing your password again",
        )
    )

    with pytest.raises(HTTPException) as exc_info:
        await user_service.reset_password(
            PasswordResetRequest(email="test@example.com"), "form_url"
        )

    assert exc_info.value.status_code == status.HTTP_403_FORBIDDEN


@pytest.mark.asyncio
async def test_update_user_not_found(user_service, mock_user_validators):
    # Given
    mock_user_validators.ensure_user_exists_by_id.side_effect = HTTPException(
        status_code=400, detail="User does not exist"
    )
    user_update = UserUpdate(email="new@example.com")

    # When/Then
    with pytest.raises(HTTPException) as exc_info:
        await user_service.update(1, 1, user_update)
    assert exc_info.value.status_code == status.HTTP_400_BAD_REQUEST


@pytest.mark.asyncio
async def test_update_user_success(
    mock_user_repository, user_service, mock_user_validators
):
    # Given
    mock_user = MagicMock(id=1)
    mock_user_validators.ensure_user_exists_by_id.return_value = mock_user
    mock_user_repository.update_user.return_value = MagicMock(
        id=1, email="new@example.com"
    )

    # When
    user_update = UserUpdate(country="Spain")
    updated_user = await user_service.update(1, 1, user_update)

    # Then
    assert updated_user.email == "new@example.com"
    mock_user_repository.update_user.assert_called_once()


@pytest.mark.asyncio
async def test_delete_user_not_found(
    user_service, mock_user_validators, mock_delete_user_token
):
    # Given
    mock_user_validators.ensure_user_exists_by_id.side_effect = HTTPException(
        status_code=400, detail="User does not exist"
    )
    mock_delete_user_token.return_value = True

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

    mock_user = MagicMock()
    mock_user.id = 1
    mock_user.email = "test@example.com"
    mock_user_repository.get_user_by_email.return_value = mock_user

    mock_hash_password.return_value = "hashed_password"
    mock_decode_url_safe_token.return_value = {"email": "test@example.com", "id": 1}

    # When
    await user_service.confirm_new_password(token, new_password_confirm)

    # Then
    mock_hash_password.assert_called_once_with("New_password_1")
    mock_user_repository.update_password.assert_called_once()

    args, _ = mock_user_repository.update_password.call_args
    assert args[1] == "hashed_password"


@pytest.mark.asyncio
async def test_confirm_new_account(
    mock_user_repository,
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
