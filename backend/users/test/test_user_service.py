import sys
from datetime import datetime, timedelta
from unittest.mock import MagicMock, AsyncMock, patch, Mock

import pytest
from fastapi import HTTPException, status
from fastapi.security import HTTPAuthorizationCredentials

from backend.settings import config
from backend.users.models import User
from backend.users.schemas import (
    UserCreate,
    UserLogin,
    UserUpdate,
    PasswordResetRequest,
)
from backend.users.service.password_service import PasswordService
from backend.users.service.user_authorisation_service import AuthorizationService

with patch.dict(sys.modules, {"backend.users.user_repository": MagicMock()}):
    from backend.users.service.user_service import UserService


@pytest.fixture
def mock_authorization_service():
    with (
        patch.object(
            AuthorizationService, "create_tokens", AsyncMock()
        ) as mock_create_tokens,
        patch.object(
            AuthorizationService, "refresh_access_token", AsyncMock()
        ) as mock_refresh_access_token,
        patch.object(
            AuthorizationService, "revoke_tokens", AsyncMock()
        ) as mock_revoke_tokens,
        patch.object(
            AuthorizationService, "create_url_safe_token", AsyncMock()
        ) as mock_create_url_token,
        patch.object(
            AuthorizationService, "decode_url_safe_token", AsyncMock()
        ) as mock_decode_url_token,
        patch.object(
            AuthorizationService, "verify_access_token", AsyncMock()
        ) as mock_verify_access_token,
        patch.object(
            AuthorizationService, "verify_refresh_token", AsyncMock()
        ) as mock_verify_refresh_token,
        patch.object(
            AuthorizationService, "extract_email_from_base64", AsyncMock()
        ) as mock_extract_email_from_base64,
    ):
        yield {
            "create_tokens": mock_create_tokens,
            "refresh_access_token": mock_refresh_access_token,
            "revoke_tokens": mock_revoke_tokens,
            "create_url_safe_token": mock_create_url_token,
            "decode_url_safe_token": mock_decode_url_token,
            "verify_access_token": mock_verify_access_token,
            "verify_refresh_token": mock_verify_refresh_token,
            "mock_extract_email_from_base64": mock_extract_email_from_base64,
        }


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
    name="TestName",
    last_name="TestLastName",
    age=19,
    country="Poland",
    email="test@example.com",
    password="Password123",
)
basic_user = User(
    id=1,
    email="test@example.com",
)


@pytest.mark.asyncio
async def test_get_existing_user(
    mock_user_repository, user_service, mock_user_validators
):
    # Given
    token_payload = {"id": "1"}
    mock_user_validators.ensure_user_exists_by_id.return_value = MagicMock(id=1)
    mock_user_repository.get_user_by_id.return_value = basic_user

    # When
    response = await user_service.get_user(token_payload)

    # Then
    assert response == basic_user


@pytest.mark.asyncio
async def test_get_unresisting_user(
    mock_user_repository, user_service, mock_user_validators
):
    # Given
    token_payload = {"id": "2"}
    mock_user_validators.ensure_user_exists_by_id.side_effect = HTTPException(
        status_code=status.HTTP_400_BAD_REQUEST, detail="User does not exist"
    )
    # When
    with pytest.raises(HTTPException) as exc_info:
        await user_service.get_user(token_payload)

    # Then
    assert exc_info.value.status_code == status.HTTP_400_BAD_REQUEST
    assert exc_info.value.detail == "User does not exist"


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
    mock_password_service, mock_user_validators, user_service
):
    # Given
    mock_user = MagicMock(password="hashed_password")
    mock_user_validators.ensure_user_exists_by_email.return_value = mock_user
    mock_password_service["verify_password"].return_value = False
    user_login = UserLogin(email="test@example.com", password="Password123")

    # When
    with pytest.raises(HTTPException) as exc_info:
        await user_service.login(user_login)

    # Then
    assert exc_info.value.status_code == status.HTTP_403_FORBIDDEN
    mock_password_service["verify_password"].assert_called_once_with(
        "Password123", "hashed_password"
    )


@pytest.mark.asyncio
async def test_login_user_success(
    mock_password_service,
    mock_authorization_service,
    mock_user_validators,
    user_service,
):
    # Given
    mock_user = MagicMock(id=1, email="test@example.com", password="hashed_password")
    mock_user_validators.ensure_user_exists_by_email.return_value = mock_user
    mock_password_service["verify_password"].return_value = True
    mock_authorization_service["create_tokens"].return_value = (
        "access_token",
        "refresh_token",
    )
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
    mock_user_validators, mock_authorization_service, user_service
):
    mock_user_validators.ensure_user_exists_by_id.return_value = MagicMock(id=1)

    response = await user_service.logout(MagicMock(), 1)

    # Then
    assert response.status_code == status.HTTP_204_NO_CONTENT
    mock_authorization_service["revoke_tokens"].assert_called_once()


@pytest.mark.asyncio
async def test_reset_password_user_unlogged(
    mock_user_validators,
    mock_email_verification_service,
    user_service,
    mock_authorization_service,
):
    # Given
    mock_user = MagicMock(
        id=1,
        email="test@example.com",
        last_password_update=datetime.now(config.TIMEZONE) - timedelta(days=2),
    )
    mock_user_validators.ensure_user_exists_by_email.return_value = mock_user
    mock_authorization_service["create_url_safe_token"].return_value = "test_token"

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
    mock_authorization_service,
):
    # Given
    mock_user = MagicMock(
        id=1,
        email="test@example.com",
        last_password_update=datetime.now(config.TIMEZONE) - timedelta(days=2),
    )
    mock_user_validators.ensure_user_exists_by_email.return_value = mock_user

    with patch.object(
        AuthorizationService, "verify_access_token", new_callable=AsyncMock
    ) as mock_verify:
        mock_verify.return_value = {
            "id": 1,
            "jti": "mock_jti",
            "linked_jti": "mock_linked_jti",
        }
        mock_authorization_service["revoke_tokens"].return_value = True

        await user_service.reset_password(
            PasswordResetRequest(
                email="test@example.com",
                token=HTTPAuthorizationCredentials(
                    scheme="Bearer", credentials="valid_token"
                ),
            ),
            "form_url",
        )

        mock_email_verification_service.process_password_reset_verification.assert_called_once()


@pytest.mark.asyncio
async def test_update_when_user_not_found(user_service, mock_user_validators):
    # Given
    mock_user_validators.ensure_user_exists_by_id.side_effect = HTTPException(
        status_code=status.HTTP_400_BAD_REQUEST, detail="User does not exist"
    )

    # When
    with pytest.raises(HTTPException) as exc_info:
        await user_service.update(
            MagicMock(), 1, UserUpdate(name="Newname", last_name="Newlastname")
        )

    # Assert
    assert exc_info.value.status_code == status.HTTP_400_BAD_REQUEST


@pytest.mark.asyncio
async def test_update_when_user_exist(
    user_service, mock_user_validators, mock_user_repository
):
    # Given
    update_user = UserUpdate(name="Newname", last_name="Newlastname")
    token_payload = {"id": "1", "jti": "fake_jti", "linked_jti": "fake_linked_jti"}
    mock_user_validators.ensure_user_exists_by_id = AsyncMock(
        spec=User, return_value=basic_user
    )
    mock_user_repository.update_user = AsyncMock(
        spec=UserUpdate, return_value=update_user
    )

    # When
    response = await user_service.update(token_payload, 1, update_user)

    # Assert
    assert response == update_user


@pytest.mark.asyncio
async def test_delete_account_when_user_not_found(user_service, mock_user_validators):
    # Given
    token_payload = {"id": "1"}
    mock_user_validators.ensure_user_exists_by_id.side_effect = HTTPException(
        status_code=status.HTTP_400_BAD_REQUEST, detail="User does not exist"
    )
    # When
    with pytest.raises(HTTPException) as exc_info:
        await user_service.delete(
            token_payload,
            1,
        )

    # Assert
    assert exc_info.value.status_code == status.HTTP_400_BAD_REQUEST


@pytest.mark.asyncio
async def test_delete_account_when_user_exist(
    user_service, mock_user_validators, mock_authorization_service, mock_user_repository
):
    # Given
    token_payload = {"id": "1", "jti": "fake_jti", "linked_jti": "fake_linked_jti"}
    mock_user_validators.ensure_user_exists_by_id = AsyncMock(
        spec=User, return_value=basic_user
    )
    mock_authorization_service["revoke_tokens"].return_value = True
    mock_user_repository.delete_user = AsyncMock(return_value=basic_user)

    # When
    response = await user_service.delete(
        token_payload,
        1,
    )

    # Assert
    assert response == basic_user


@pytest.mark.asyncio
async def test_confirm_new_account_successfully(
    user_service, mock_user_validators, mock_authorization_service
):
    # Given
    mock_authorization_service["decode_url_safe_token"].return_value = {
        "email": "test@email.com"
    }
    mock_user_validators.ensure_user_exists_by_email = AsyncMock(
        return_value=basic_user
    )

    # When
    response = await user_service.confirm_new_account("test_token")

    # Assert
    assert response.status_code == 302
    assert (
        response.headers["location"] == "http://localhost:3000/#/login?status=success"
    )


@pytest.mark.asyncio
async def test_confirm_new_account_with_revoked_token(
    user_service, mock_user_validators, mock_authorization_service
):
    # Given
    mock_authorization_service["decode_url_safe_token"].side_effect = HTTPException(
        status_code=401,
        detail="Token verification failed",
    )
    mock_authorization_service[
        "mock_extract_email_from_base64"
    ].return_value = "test@example.com"
    mock_user_validators.ensure_user_exists_by_email = AsyncMock(
        return_value=basic_user
    )

    # When
    response = await user_service.confirm_new_account("revoked_token")

    # Assert
    assert response.status_code == 302
    assert (
        response.headers["location"]
        == "http://localhost:3000/#/login?status=error&email=test@example.com"
    )


@pytest.mark.asyncio
async def test_confirm_new_account_with_corrupted_token(
    user_service, mock_user_validators, mock_authorization_service
):
    # Given
    mock_authorization_service["decode_url_safe_token"].side_effect = HTTPException(
        status_code=401,
        detail="Token verification failed",
    )
    mock_authorization_service["mock_extract_email_from_base64"].return_value = None
    mock_user_validators.ensure_user_exists_by_email = AsyncMock(
        spec=User, return_value=basic_user
    )

    # When
    response = await user_service.confirm_new_account("corrupted token")

    # Assert
    assert response.status_code == 302
    assert response.headers["location"] == "http://localhost:3000/#/login?status=error"
