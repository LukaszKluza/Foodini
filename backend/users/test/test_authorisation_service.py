from datetime import datetime, timedelta
from unittest.mock import patch, AsyncMock

import pytest
import redis.asyncio as aioredis
from fastapi import HTTPException, status
from fastapi.security import HTTPAuthorizationCredentials

from backend.Settings import ACCESS_TOKEN_EXPIRE_MINUTES
from backend.users.service.authorisation_service import AuthorizationService


@pytest.fixture
def mock_redis():
    mock_redis_instance = AsyncMock(spec=aioredis.Redis)
    mock_redis_instance.setex = AsyncMock(return_value=None)
    mock_redis_instance.get = AsyncMock(return_value=b"test_token")
    return mock_redis_instance


@pytest.fixture
def mock_jwt():
    with patch("jwt.decode") as mock_decode, patch("jwt.encode") as mock_encode:
        yield mock_decode, mock_encode


@pytest.fixture
def credentials():
    return HTTPAuthorizationCredentials(scheme="Bearer", credentials="test_token")


@pytest.mark.asyncio
async def test_create_tokens(mock_redis, mock_jwt):
    mock_jwt[1].return_value = "encoded_token"
    data = {"id": 1, "username": "test_user"}

    with patch(
        "backend.users.service.authorisation_service.get_redis", return_value=mock_redis
    ):
        access_token, refresh_token = await AuthorizationService.create_tokens(data)

        assert access_token == "encoded_token"
        assert refresh_token == "encoded_token"
        mock_redis.setex.assert_called_once_with(
            1, ACCESS_TOKEN_EXPIRE_MINUTES * 60, "encoded_token"
        )


@pytest.mark.asyncio
async def test_refresh_access_token(mock_redis, mock_jwt, credentials):
    mock_jwt[0].return_value = {
        "id": 1,
        "exp": datetime.utcnow() + timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES),
    }
    mock_jwt[1].return_value = "encoded_token"
    mock_redis.get.return_value = b"test_token"

    new_token = await AuthorizationService.refresh_access_token(credentials, mock_redis)

    assert new_token == "encoded_token"
    mock_redis.setex.assert_called_once_with(
        1, ACCESS_TOKEN_EXPIRE_MINUTES * 60, "encoded_token"
    )


@pytest.mark.asyncio
async def test_verify_token(mock_redis, mock_jwt, credentials):
    mock_jwt[0].return_value = {"id": 1}
    mock_redis.get.return_value = b"test_token"

    token = await AuthorizationService.verify_token(credentials, mock_redis)

    assert token == {"id": 1}


@pytest.mark.asyncio
async def test_verify_token_revoked(mock_redis, mock_jwt, credentials):
    mock_jwt[0].return_value = {"id": 1}
    mock_redis.get.return_value = b"other_token"

    with pytest.raises(HTTPException) as excinfo:
        await AuthorizationService.verify_token(credentials, mock_redis)

    assert excinfo.value.status_code == status.HTTP_401_UNAUTHORIZED
    assert excinfo.value.detail == "Invalid or revoked token"
