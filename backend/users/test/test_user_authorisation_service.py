from datetime import datetime, timedelta
from unittest.mock import patch, AsyncMock, MagicMock
import pytest
import jwt
import redis.asyncio as aioredis
from fastapi import HTTPException, status
from fastapi.security import HTTPAuthorizationCredentials
from itsdangerous import BadSignature

from backend.settings import config
from backend.users.service.user_authorisation_service import AuthorizationService


@pytest.fixture
def mock_redis():
    redis_mock = AsyncMock(spec=aioredis.Redis)
    redis_mock.setex = AsyncMock()
    redis_mock.get = AsyncMock()
    redis_mock.delete = AsyncMock()
    return redis_mock


@pytest.fixture
def valid_payload():
    return {
        "id": 1,
        "sub": "user@example.com",
        "exp": datetime.now(config.TIMEZONE) + timedelta(minutes=30),
    }


@pytest.fixture
def expired_payload():
    return {
        "id": 1,
        "sub": "user@example.com",
        "exp": datetime.now(config.TIMEZONE) - timedelta(minutes=30),
    }


@pytest.fixture
def credentials():
    return HTTPAuthorizationCredentials(scheme="Bearer", credentials="valid_token")


@pytest.mark.asyncio
async def test_create_tokens_success(mock_redis):
    with (
        patch("jwt.encode", side_effect=["access_token", "refresh_token"]),
        patch(
            "backend.users.service.user_authorisation_service.get_redis",
            return_value=mock_redis,
        ),
    ):
        access, refresh = await AuthorizationService.create_tokens({"id": 1})

        assert access == "access_token"
        assert refresh == "refresh_token"
        mock_redis.setex.assert_called_once_with(
            1, config.ACCESS_TOKEN_EXPIRE_MINUTES * 60, "access_token"
        )


@pytest.mark.asyncio
async def test_create_tokens_redis_error():
    with patch(
        "backend.users.service.user_authorisation_service.get_redis",
        return_value=None,
    ):
        with pytest.raises(HTTPException) as exc:
            await AuthorizationService.create_tokens({"id": 1})
        assert exc.value.status_code == status.HTTP_500_INTERNAL_SERVER_ERROR


@pytest.mark.asyncio
async def test_verify_token_success(mock_redis, credentials, valid_payload):
    with (
        patch("jwt.decode", return_value=valid_payload),
        patch(
            "backend.users.service.user_authorisation_service.get_redis",
            return_value=mock_redis,
        ),
    ):
        mock_redis.get.return_value = b"valid_token"
        result = await AuthorizationService.verify_token(credentials, mock_redis)

        assert result == valid_payload


@pytest.mark.asyncio
async def test_verify_token_expired(credentials, expired_payload):
    with patch("jwt.decode", return_value=expired_payload):
        with pytest.raises(HTTPException) as exc:
            await AuthorizationService.verify_token(credentials, AsyncMock())
        assert exc.value.status_code == status.HTTP_401_UNAUTHORIZED


@pytest.mark.asyncio
async def test_refresh_token_success(mock_redis, credentials, valid_payload):
    with (
        patch("jwt.decode", return_value=valid_payload),
        patch("jwt.encode", return_value="new_token"),
    ):
        mock_redis.get.return_value = b"valid_token"
        new_token = await AuthorizationService.refresh_access_token(
            credentials, mock_redis
        )

        assert new_token == "new_token"
        mock_redis.setex.assert_called_once()


@pytest.mark.asyncio
async def test_delete_user_token_success(mock_redis):
    with patch(
        "backend.users.service.user_authorisation_service.get_redis",
        return_value=mock_redis,
    ):
        await AuthorizationService.delete_user_token(1)
        mock_redis.delete.assert_called_once_with(1)


@pytest.mark.asyncio
async def test_create_url_safe_token():
    mock_serializer = MagicMock()
    mock_serializer.dumps.return_value = "safe_token"

    with patch(
        "backend.users.service.user_authorisation_service.URLSafeTimedSerializer",
        return_value=mock_serializer,
    ):
        token = await AuthorizationService.create_url_safe_token(
            {"email": "test@example.com"}
        )
        assert token == "safe_token"


@pytest.mark.asyncio
async def test_decode_url_safe_token_invalid():
    mock_serializer = MagicMock()
    mock_serializer.loads.side_effect = BadSignature("Invalid")

    with patch(
        "backend.users.service.user_authorisation_service.URLSafeTimedSerializer",
        return_value=mock_serializer,
    ):
        with pytest.raises(HTTPException) as exc:
            await AuthorizationService.decode_url_safe_token("invalid_token")
        assert exc.value.status_code == status.HTTP_401_UNAUTHORIZED


@pytest.mark.asyncio
async def test_get_payload_from_token_invalid(credentials):
    with patch("jwt.decode", side_effect=jwt.InvalidTokenError):
        with pytest.raises(HTTPException) as exc:
            await AuthorizationService.get_payload_from_token(credentials)
        assert exc.value.status_code == status.HTTP_401_UNAUTHORIZED
