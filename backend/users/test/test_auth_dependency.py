import uuid
from datetime import datetime, timedelta
from unittest.mock import AsyncMock, Mock

import pytest
from fastapi.security import OAuth2PasswordBearer
from pydantic import EmailStr, TypeAdapter

from backend.models import User
from backend.settings import config
from backend.users.auth_dependencies import AuthDependency
from backend.users.enums.role import Role
from backend.users.enums.token import Token
from backend.users.schemas import RefreshTokensResponse, TokenPayload


@pytest.fixture
def mock_user():
    return User(id=uuid.UUID("6ea7ae4d-fc73-4db0-987d-84e8e2bc2a6a"), email="test@example.com", is_verified=True)


@pytest.fixture
def mock_oauth_token(monkeypatch):
    token = "mock-token"

    def mock_call(*args, **kwargs):
        return token

    monkeypatch.setattr(OAuth2PasswordBearer, "__call__", mock_call)
    return token


@pytest.fixture
def mock_user_validators(mock_user):
    mock = AsyncMock()
    mock.check_user_permission = Mock()
    mock.ensure_user_exists_by_id = AsyncMock(return_value=mock_user)
    mock.ensure_verified_user = Mock()
    return mock


@pytest.fixture
def mock_authorization_service():
    mock = AsyncMock()
    mock.verify_access_token = AsyncMock(
        return_value=TokenPayload(
            id=uuid.UUID("6ea7ae4d-fc73-4db0-987d-84e8e2bc2a6a"),
            email=TypeAdapter(EmailStr).validate_python("test@example.com"),
            jti="jti",
            linked_jti="linked_jti",
            exp=datetime.now(config.TIMEZONE) + timedelta(minutes=30),
            type=Token.ACCESS,
            role=Role.USER,
        )
    )
    mock.refresh_tokens = AsyncMock(
        return_value=RefreshTokensResponse(
            id=uuid.UUID("6ea7ae4d-fc73-4db0-987d-84e8e2bc2a6a"),
            email=TypeAdapter(EmailStr).validate_python("test@example.com"),
            access_token="new_access",
            refresh_token="new_refresh",
        )
    )
    return mock


@pytest.fixture
def auth_dependency(mock_user_validators, mock_authorization_service, mock_oauth_token):
    return AuthDependency(
        user_id=uuid.UUID("6ea7ae4d-fc73-4db0-987d-84e8e2bc2a6a"),
        user_validators=mock_user_validators,
        authorization_service=mock_authorization_service,
        token=mock_oauth_token,
    )


@pytest.mark.asyncio
async def test_get_current_user(auth_dependency, mock_user_validators, mock_user):
    user, token = await auth_dependency.get_current_user()

    assert user == mock_user
    assert token.id == uuid.UUID("6ea7ae4d-fc73-4db0-987d-84e8e2bc2a6a")

    mock_user_validators.check_user_permission.assert_called_once_with(
        uuid.UUID("6ea7ae4d-fc73-4db0-987d-84e8e2bc2a6a"), uuid.UUID("6ea7ae4d-fc73-4db0-987d-84e8e2bc2a6a")
    )
    mock_user_validators.ensure_user_exists_by_id.assert_awaited_once_with(
        uuid.UUID("6ea7ae4d-fc73-4db0-987d-84e8e2bc2a6a")
    )
    mock_user_validators.ensure_verified_user.assert_called_once_with(mock_user)


@pytest.mark.asyncio
async def test_get_refreshed_tokens(auth_dependency, mock_authorization_service):
    tokens = await auth_dependency.get_refreshed_tokens()

    assert tokens.access_token == "new_access"
    assert tokens.refresh_token == "new_refresh"
    mock_authorization_service.refresh_tokens.assert_awaited_once()
