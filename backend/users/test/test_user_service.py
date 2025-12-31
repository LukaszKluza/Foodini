import sys
import uuid
from datetime import datetime, timedelta, timezone
from unittest.mock import ANY, AsyncMock, MagicMock, Mock, patch

import pytest
from fastapi import HTTPException, status
from fastapi.security import OAuth2PasswordRequestForm
from pydantic import EmailStr, TypeAdapter

from backend.core.not_found_in_database_exception import NotFoundInDatabaseException
from backend.models import User
from backend.settings import config
from backend.users.enums.language import Language
from backend.users.enums.role import Role
from backend.users.enums.token import Token
from backend.users.schemas import (
    NewPasswordConfirm,
    PasswordResetRequest,
    TokenPayload,
    UserCreate,
    UserUpdate,
)
from backend.users.service.password_service import PasswordService

with patch.dict(sys.modules, {"backend.users.user_repository": MagicMock()}):
    from backend.users.service.user_service import UserService


@pytest.fixture
def mock_password_service():
    with (
        patch.object(PasswordService, "hash_password", AsyncMock()) as mock_hash,
        patch.object(PasswordService, "verify_password", AsyncMock()) as mock_verify,
    ):
        yield {"hash_password": mock_hash, "verify_password": mock_verify}


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
    mock.ensure_verified_user = Mock()
    mock.check_user_permission = Mock()
    mock.check_last_password_change_data_time = Mock()
    mock.ensure_user_exists_by_id = AsyncMock()
    return mock


@pytest.fixture
def mock_authorization_service():
    mock = MagicMock()
    mock.create_tokens = AsyncMock()
    mock.revoke_tokens = AsyncMock()
    mock.create_url_safe_token = AsyncMock()
    mock.extract_email_from_base64 = AsyncMock()
    mock.extract_language_from_base64 = AsyncMock()
    mock.decode_url_safe_token = AsyncMock()
    mock.verify_access_token = AsyncMock()
    return mock


@pytest.fixture
def user_service(
    mock_user_repository,
    mock_email_verification_service,
    mock_user_validators,
    mock_authorization_service,
):
    return UserService(
        user_repository=mock_user_repository,
        email_verification_service=mock_email_verification_service,
        user_validators=mock_user_validators,
        authorization_service=mock_authorization_service,
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
    repo.get_role_id_by_role_name = AsyncMock(return_value=MagicMock(id=uuid.uuid4()))
    repo.get_role_by_id = AsyncMock(return_value=Role.USER)
    return repo


user_create = UserCreate(
    name="TestName",
    last_name="TestLastName",
    country="Poland",
    email=TypeAdapter(EmailStr).validate_python("test@example.com"),
    password="Password123",
    language=Language.EN,
)

basic_user = User(
    id=uuid.UUID("6ea7ae4d-fc73-4db0-987d-84e8e2bc2a6a"),
    email="test@example.com",
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
    mock_password_service,
    mock_user_repository,
    mock_email_verification_service,
    user_service,
):
    # Given
    mock_user_repository.get_user_by_email.return_value = None
    mock_password_service["hash_password"].return_value = "hashed_password"
    mock_user_repository.create_user.return_value = MagicMock(
        id=uuid.UUID("6ea7ae4d-fc73-4db0-987d-84e8e2bc2a6a"), email="test@example.com"
    )

    # When
    new_user = await user_service.register(user_create)

    # Then
    assert new_user.email == "test@example.com"
    mock_email_verification_service.process_new_account_verification.assert_called_once()


@pytest.mark.asyncio
async def test_login_user_not_found(user_service, mock_user_validators):
    # Given
    form = OAuth2PasswordRequestForm(
        username="test@example.com",
        password="Password123",
        scope="",
        grant_type="",
        client_id=None,
        client_secret=None,
    )
    mock_user_validators.ensure_user_exists_by_email.side_effect = NotFoundInDatabaseException("User not found")

    # When/Then
    with pytest.raises(NotFoundInDatabaseException) as exc_info:
        await user_service.login(form)

    assert exc_info.value.detail == "User not found"


@pytest.mark.asyncio
async def test_login_user_incorrect_password(mock_password_service, mock_user_validators, user_service):
    # Given
    mock_user = MagicMock(password="hashed_password")
    form = OAuth2PasswordRequestForm(
        username="test@example.com",
        password="Password123",
        scope="",
        grant_type="",
        client_id=None,
        client_secret=None,
    )
    mock_user_validators.ensure_user_exists_by_email.return_value = mock_user
    mock_password_service["verify_password"].return_value = False

    # When
    with pytest.raises(HTTPException) as exc_info:
        await user_service.login(form)

    # Then
    assert exc_info.value.status_code == status.HTTP_403_FORBIDDEN
    mock_password_service["verify_password"].assert_called_once_with("Password123", "hashed_password")


@pytest.mark.asyncio
async def test_login_user_success(
    mock_password_service,
    mock_authorization_service,
    mock_user_validators,
    user_service,
):
    # Given
    mock_user = User(
        id=uuid.UUID("6ea7ae4d-fc73-4db0-987d-84e8e2bc2a6a"), email="test@example.com", password="hashed_password"
    )
    mock_user_validators.ensure_user_exists_by_email.return_value = mock_user
    mock_password_service["verify_password"].return_value = True
    mock_authorization_service.create_tokens.return_value = (
        b"access_token",
        b"refresh_token",
    )
    form = OAuth2PasswordRequestForm(
        username="test@example.com",
        password="Password123",
        scope="",
        grant_type="",
        client_id=None,
        client_secret=None,
    )

    # When
    result = await user_service.login(form)

    # Then
    assert result.email == "test@example.com"
    assert result.access_token == "access_token"


@pytest.mark.asyncio
async def test_logout_user_success(mock_user_validators, mock_authorization_service, user_service):
    response = await user_service.logout(
        TokenPayload(
            id=uuid.UUID("6ea7ae4d-fc73-4db0-987d-84e8e2bc2a6a"),
            jti="jti",
            linked_jti="linked_jti",
            email="test@example.com",
            exp=datetime.now(timezone.utc),
            type=Token.ACCESS,
            role=Role.USER,
        )
    )

    # Then
    assert response.status_code == status.HTTP_204_NO_CONTENT
    mock_authorization_service.revoke_tokens.assert_called_once()


@pytest.mark.asyncio
async def test_reset_password_user_unlogged(
    mock_user_validators,
    mock_email_verification_service,
    user_service,
    mock_authorization_service,
):
    # Given
    mock_user = MagicMock(
        id=uuid.UUID("6ea7ae4d-fc73-4db0-987d-84e8e2bc2a6a"),
        email="test@example.com",
        last_password_update=datetime.now(config.TIMEZONE) - timedelta(days=2),
    )
    mock_user_validators.ensure_user_exists_by_email.return_value = mock_user
    mock_authorization_service.create_url_safe_token.return_value = "test_token"

    # When
    await user_service.reset_password(
        PasswordResetRequest(email=TypeAdapter(EmailStr).validate_python("test@example.com")),
        "form_url",
    )

    # Then
    mock_email_verification_service.process_password_reset_verification.assert_called_once()


@pytest.mark.asyncio
async def test_reset_password_user_logged_successful(
    mock_user_validators,
    mock_email_verification_service,
    user_service,
    mock_authorization_service,
):
    # Given
    mock_user = MagicMock(
        id=uuid.UUID("6ea7ae4d-fc73-4db0-987d-84e8e2bc2a6a"),
        email="test@example.com",
        last_password_update=datetime.now(config.TIMEZONE) - timedelta(days=2),
    )
    mock_user_validators.ensure_user_exists_by_email.return_value = mock_user

    mock_authorization_service.verify_access_token.return_value = {
        "id": 1,
        "jti": "mock_jti",
        "linked_jti": "mock_linked_jti",
    }
    mock_authorization_service["revoke_tokens"].return_value = True

    await user_service.reset_password(
        PasswordResetRequest(email=TypeAdapter(EmailStr).validate_python("test@example.com")),
        "form_url",
    )

    mock_email_verification_service.process_password_reset_verification.assert_called_once()


@pytest.mark.asyncio
async def test_reset_password_too_early(
    user_service,
    mock_user_validators,
    mock_authorization_service,
):
    # Given
    password_reset_data = PasswordResetRequest(email=TypeAdapter(EmailStr).validate_python("test@example.com"))
    user_ = type("User", (), {"id": uuid.UUID("6ea7ae4d-fc73-4db0-987d-84e8e2bc2a6a"), "email": "test@example.com"})()

    mock_user_validators.ensure_user_exists_by_email.return_value = user_
    mock_user_validators.ensure_verified_user.return_value = None

    mock_user_validators.check_last_password_change_data_time.side_effect = HTTPException(
        status_code=status.HTTP_403_FORBIDDEN,
        detail="You must wait at least 1 day before changing your password again",
    )

    # When / Then
    with pytest.raises(HTTPException) as exc_info:
        await user_service.reset_password(password_reset_data, form_url="https://reset.example.com")

    assert exc_info.value.status_code == status.HTTP_403_FORBIDDEN
    assert "1 day" in exc_info.value.detail

    mock_user_validators.check_last_password_change_data_time.assert_called_once_with(user_)


@pytest.mark.asyncio
async def test_update_when_user_exist(user_service, mock_user_validators, mock_user_repository):
    # Given
    update_user = UserUpdate(name="Newname", last_name="NewLastName")
    mock_user_validators.ensure_user_exists_by_id.return_value = basic_user
    mock_user_repository.update_user.return_value = update_user

    # When
    response = await user_service.update(basic_user, update_user)

    # Assert
    assert response == update_user


@pytest.mark.asyncio
async def test_delete_account_when_user_exist(
    user_service, mock_user_validators, mock_authorization_service, mock_user_repository
):
    # Given
    token_payload = TokenPayload(
        id=uuid.UUID("6ea7ae4d-fc73-4db0-987d-84e8e2bc2a6a"),
        jti="fake_jti",
        linked_jti="fake_linked_jti",
        email="test@example.com",
        exp=datetime.now(timezone.utc),
        type=Token.ACCESS,
        role=Role.USER,
    )

    mock_authorization_service.revoke_tokens.return_value = True
    mock_user_repository.delete_user.return_value = basic_user

    # When
    response = await user_service.delete(
        basic_user,
        token_payload,
    )

    # Assert
    assert response == basic_user
    mock_authorization_service.revoke_tokens.assert_called_once_with("fake_jti", "fake_linked_jti")


@pytest.mark.asyncio
async def test_confirm_new_account_successfully(user_service, mock_user_validators, mock_authorization_service):
    # Given
    mock_authorization_service.decode_url_safe_token.return_value = {"email": "test@email.com"}
    mock_authorization_service.extract_email_from_base64.return_value = "test@email.com"
    mock_authorization_service.extract_language_from_base64.return_value = None

    # When
    response = await user_service.confirm_new_account("test_token")

    # Assert
    assert response.status_code == 302
    assert response.headers["location"] == "https://foodini.com.pl/#/login?status=success&email=test@email.com"


@pytest.mark.asyncio
async def test_confirm_new_account_with_revoked_token(user_service, mock_user_validators, mock_authorization_service):
    # Given
    mock_authorization_service.decode_url_safe_token.side_effect = HTTPException(
        status_code=400,
        detail="Token verification failed",
    )
    mock_authorization_service.extract_email_from_base64.return_value = "test@example.com"
    mock_authorization_service.extract_language_from_base64.return_value = "PL"
    mock_user_validators.ensure_user_exists_by_email.return_value = basic_user

    # When
    response = await user_service.confirm_new_account("revoked_token")

    # Assert
    assert response.status_code == 302
    assert (
        response.headers["location"] == "https://foodini.com.pl/#/login?status=error&email=test@example.com&language=PL"
    )


@pytest.mark.asyncio
async def test_confirm_new_account_with_corrupted_token(user_service, mock_user_validators, mock_authorization_service):
    # Given
    mock_authorization_service.decode_url_safe_token.side_effect = HTTPException(
        status_code=400,
        detail="Token verification failed",
    )
    mock_authorization_service.extract_email_from_base64.return_value = None
    mock_authorization_service.extract_language_from_base64.return_value = "PL"
    mock_user_validators.ensure_user_exists_by_email.return_value = basic_user

    # When
    response = await user_service.confirm_new_account("corrupted token")

    # Assert
    assert response.status_code == 302
    assert response.headers["location"] == "https://foodini.com.pl/#/login?status=error&language=PL"


@pytest.mark.asyncio
async def test_confirm_new_password_success(
    user_service,
    mock_user_validators,
    mock_user_repository,
    mock_password_service,
    mock_authorization_service,
):
    # Given
    new_password_data = NewPasswordConfirm(
        email=TypeAdapter(EmailStr).validate_python("test@example.com"),
        password="NewPassword123",
        token="valid_token",
    )

    user_ = type("User", (), {"id": uuid.UUID("6ea7ae4d-fc73-4db0-987d-84e8e2bc2a6a"), "email": "test@example.com"})()
    mock_user_validators.ensure_user_exists_by_email.return_value = user_

    mock_authorization_service.decode_url_safe_token.return_value = {"email": "test@example.com"}

    mock_password_service["hash_password"].return_value = "hashed_password"
    mock_user_repository.update_password.return_value = {"success": True}

    # When
    response = await user_service.confirm_new_password(new_password_data)

    # Then
    assert response == {"success": True}
    mock_user_validators.ensure_user_exists_by_email.assert_called_with("test@example.com")
    mock_authorization_service.decode_url_safe_token.assert_awaited_once_with("valid_token", ANY)
    mock_user_validators.check_user_permission.assert_called_once_with("test@example.com", "test@example.com")
    mock_password_service["hash_password"].assert_awaited_once_with("NewPassword123")
    mock_user_repository.update_password.assert_awaited_once()


@pytest.mark.asyncio
async def test_confirm_new_password_invalid_token(user_service, mock_user_validators, mock_authorization_service):
    # Given
    new_password_data = NewPasswordConfirm(
        email=TypeAdapter(EmailStr).validate_python("test@example.com"),
        password="NewPassword123",
        token="invalid_token",
    )

    user_ = type("User", (), {"id": uuid.UUID("6ea7ae4d-fc73-4db0-987d-84e8e2bc2a6a"), "email": "test@example.com"})()
    mock_user_validators.ensure_user_exists_by_email.return_value = user_

    mock_authorization_service.decode_url_safe_token.side_effect = Exception("Decode failed")

    # When
    with pytest.raises(Exception) as exc_info:
        await user_service.confirm_new_password(new_password_data)

    # Then
    assert str(exc_info.value) == "Decode failed"

    mock_authorization_service.decode_url_safe_token.assert_awaited_once_with("invalid_token", ANY)


@pytest.mark.asyncio
async def test_confirm_new_password_missing_token(user_service, mock_user_validators, mock_authorization_service):
    # Given
    new_password_data = NewPasswordConfirm(
        email=TypeAdapter(EmailStr).validate_python("test@example.com"),
        password="NewPassword123",
        token="",
    )
    user_ = type("User", (), {"id": uuid.UUID("6ea7ae4d-fc73-4db0-987d-84e8e2bc2a6a"), "email": "test@example.com"})()

    mock_authorization_service.decode_url_safe_token.side_effect = HTTPException(
        status_code=400,
        detail="Token verification failed",
    )
    mock_user_validators.ensure_user_exists_by_email.return_value = user_

    # When
    with pytest.raises(HTTPException) as exc_info:
        await user_service.confirm_new_password(new_password_data)

    # Then
    assert exc_info.value.status_code == status.HTTP_400_BAD_REQUEST
    assert exc_info.value.detail == "Token verification failed"
