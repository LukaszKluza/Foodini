from datetime import datetime, timedelta
from unittest.mock import patch, AsyncMock, MagicMock, Mock

import jwt
import pytest
import redis.asyncio as aioredis
from fastapi import HTTPException, status
from fastapi.security import HTTPAuthorizationCredentials
from itsdangerous import BadSignature

from backend.settings import config
from backend.users.enums.token import Token
from backend.core.user_authorisation_service import AuthorizationService


@pytest.fixture
def mock_redis():
    redis_mock = AsyncMock(spec=aioredis.Redis)
    redis_mock.setex = AsyncMock()
    redis_mock.get = AsyncMock()
    redis_mock.exists = AsyncMock()
    redis_mock.delete = AsyncMock()

    pipe_mock = AsyncMock()
    pipe_mock.setex = AsyncMock()
    pipe_mock.exists = Mock()
    pipe_mock.execute = AsyncMock()

    pipeline_cm = AsyncMock()
    pipeline_cm.__aenter__.return_value = pipe_mock
    pipeline_cm.__aexit__.return_value = None

    redis_mock.pipeline.return_value = pipeline_cm

    return redis_mock


@pytest.fixture
def valid_payload():
    return {
        "jti": "token_id",
        "linked_jti": "linked_token_id",
        "id": 1,
        "sub": "user@example.com",
        "type": Token.ACCESS.value,
        "exp": datetime.now(config.TIMEZONE) + timedelta(minutes=30),
    }


@pytest.fixture
def valid_refresh_payload():
    return {
        "jti": "refresh_token_id",
        "linked_jti": "access_token_id",
        "id": 1,
        "sub": "user@example.com",
        "type": Token.REFRESH.value,
        "exp": datetime.now(config.TIMEZONE) + timedelta(minutes=60),
    }


@pytest.fixture
def expired_payload():
    return {
        "jti": "token_id",
        "linked_jti": "linked_token_id",
        "id": 1,
        "sub": "user@example.com",
        "exp": datetime.now(config.TIMEZONE) - timedelta(minutes=30),
    }


@pytest.fixture
def credentials():
    return HTTPAuthorizationCredentials(scheme="Bearer", credentials="valid_token")


@pytest.mark.asyncio
async def test_create_tokens_success(mock_redis):
    # given
    with (
        patch("jwt.encode", side_effect=["access_token", "refresh_token"]),
        patch(
            "backend.core.user_authorisation_service.get_redis",
            return_value=mock_redis,
        ),
        patch("uuid.uuid4", side_effect=["access_jti", "refresh_jti"]),
    ):
        # when
        access, refresh = await AuthorizationService.create_tokens({"id": 1})

        # then
        assert access == "access_token"
        assert refresh == "refresh_token"
        mock_redis.setex.assert_called_once_with(
            "refresh_jti", config.REFRESH_TOKEN_EXPIRE_HOURS * 3600, "refresh_token"
        )


@pytest.mark.asyncio
async def test_create_tokens_redis_error():
    # given
    with patch(
        "backend.core.user_authorisation_service.get_redis",
        return_value=None,
    ):
        # when / then
        with pytest.raises(HTTPException) as exc:
            await AuthorizationService.create_tokens({"id": 1})
        assert exc.value.status_code == status.HTTP_500_INTERNAL_SERVER_ERROR


@pytest.mark.asyncio
async def test_verify_token_success(mock_redis, credentials, valid_payload):
    # given
    with (
        patch.object(
            AuthorizationService,
            "get_payload_from_token",
            return_value=valid_payload,
        ),
        patch(
            "backend.core.user_authorisation_service.get_redis",
            return_value=mock_redis,
        ),
    ):
        mock_redis.get.side_effect = [b"token_data", None]
        mock_redis.pipeline.return_value.exists.return_value = False
        mock_redis.pipeline.return_value.execute.return_value = [0, 0]

        # when
        result = await AuthorizationService.verify_access_token(credentials)

        # then
        assert result == valid_payload


@pytest.mark.asyncio
async def test_verify_token_expired(credentials):
    # given
    with patch.object(
        AuthorizationService,
        "get_payload_from_token",
        side_effect=HTTPException(status.HTTP_401_UNAUTHORIZED, "Invalid token"),
    ):
        # when / then
        with pytest.raises(HTTPException) as exc:
            await AuthorizationService.verify_access_token(credentials)
        assert exc.value.status_code == status.HTTP_401_UNAUTHORIZED


@pytest.mark.asyncio
async def test_refresh_token_success(mock_redis, credentials, valid_refresh_payload):
    # given
    with (
        patch.object(
            AuthorizationService,
            "verify_refresh_token",
            return_value=valid_refresh_payload,
        ),
        patch.object(
            AuthorizationService,
            "create_tokens",
            return_value=("new_access", "new_refresh"),
        ),
        patch.object(
            AuthorizationService,
            "revoke_tokens",
            new_callable=AsyncMock,
        ),
        patch(
            "backend.core.user_authorisation_service.get_redis",
            return_value=mock_redis,
        ),
    ):
        mock_redis.get.return_value = b"valid_token"

        # when
        result = await AuthorizationService.refresh_access_token(credentials)

        # then
        assert result == {"access_token": "new_access", "refresh_token": "new_refresh"}
        AuthorizationService.revoke_tokens.assert_awaited_once_with(
            valid_refresh_payload["jti"], valid_refresh_payload["linked_jti"]
        )


@pytest.mark.asyncio
async def test_revoke_tokens_success(mock_redis):
    # given
    with patch(
        "backend.core.user_authorisation_service.get_redis",
        return_value=mock_redis,
    ):
        # when
        await AuthorizationService.revoke_tokens("token_jti", "linked_jti")

        # then
        pipe = mock_redis.pipeline.return_value.__aenter__.return_value
        pipe.setex.assert_any_call(
            "blacklist:token_jti",
            config.REFRESH_TOKEN_EXPIRE_HOURS * 3600,
            Token.REVOKED.value,
        )
        pipe.setex.assert_any_call(
            "blacklist:linked_jti",
            config.REFRESH_TOKEN_EXPIRE_HOURS * 3600,
            Token.REVOKED.value,
        )
        pipe.execute.assert_awaited_once()


@pytest.mark.asyncio
async def test_create_url_safe_token():
    # given
    mock_serializer = MagicMock()
    mock_serializer.dumps.return_value = "safe_token"

    with patch(
        "backend.core.user_authorisation_service.URLSafeTimedSerializer",
        return_value=mock_serializer,
    ):
        # when
        token = await AuthorizationService.create_url_safe_token(
            {"email": "test@example.com"}
        )

        # then
        assert token == "safe_token"


@pytest.mark.asyncio
async def test_decode_url_safe_token_invalid():
    # given
    mock_serializer = MagicMock()
    mock_serializer.loads.side_effect = BadSignature("Invalid")

    with patch(
        "backend.core.user_authorisation_service.URLSafeTimedSerializer",
        return_value=mock_serializer,
    ):
        # when / then
        with pytest.raises(HTTPException) as exc:
            await AuthorizationService.decode_url_safe_token("invalid_token")
        assert exc.value.status_code == status.HTTP_401_UNAUTHORIZED


@pytest.mark.asyncio
async def test_get_payload_from_token_invalid(credentials):
    # given
    with patch("jwt.decode", side_effect=jwt.InvalidTokenError):
        # when / then
        with pytest.raises(HTTPException) as exc:
            await AuthorizationService.get_payload_from_token(credentials)
        assert exc.value.status_code == status.HTTP_403_FORBIDDEN
