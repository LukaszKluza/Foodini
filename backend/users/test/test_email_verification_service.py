from unittest.mock import AsyncMock, MagicMock, Mock

import pytest
from fastapi import HTTPException, status
from fastapi_mail import MessageSchema, MessageType
from pydantic import EmailStr, TypeAdapter

from backend.settings import config
from backend.users.service.email_verification_service import EmailVerificationService


@pytest.fixture
def email_verification_service(
    mock_user_repository,
    mock_user_validators,
    mock_mail_service,
    mock_authorization_service,
):
    return EmailVerificationService(
        user_repository=mock_user_repository,
        user_validators=mock_user_validators,
        mail_service=mock_mail_service,
        authorization_service=mock_authorization_service,
    )


@pytest.fixture
def mock_user_repository():
    repo = MagicMock()
    repo.get_user_by_email = AsyncMock()
    return repo


@pytest.fixture
def mock_user_validators():
    validators = MagicMock()
    validators.ensure_user_exists_by_email = AsyncMock()
    return validators


@pytest.fixture
def mock_mail_service():
    mail_service = MagicMock()
    mail_service.build_message = AsyncMock()
    mail_service.send_message = AsyncMock()
    return mail_service


@pytest.fixture
def mock_authorization_service():
    mock = MagicMock()
    mock.create_tokens = AsyncMock()
    mock.refresh_tokens = Mock()
    mock.revoke_tokens = AsyncMock()
    mock.create_url_safe_token = AsyncMock()
    mock.decode_url_safe_token = AsyncMock()
    mock.verify_access_token = AsyncMock()
    mock.verify_refresh_token = AsyncMock()
    mock.extract_email_from_base64 = AsyncMock()
    return mock


test_email = TypeAdapter(EmailStr).validate_python("test@example.com")
test_token = "test_token"


@pytest.mark.asyncio
async def test_send_new_account_verification(email_verification_service, mock_mail_service):
    email_verification_service.templates = MagicMock()
    email_verification_service.templates.get_template.return_value.render.return_value = (
        "Please click this link: http://localhost:8000/v1/users/confirm/new-account?url_token=test_token"
        " to verify your email."
    )

    await email_verification_service._send_new_account_verification(test_email, test_token)

    mock_mail_service.build_message.assert_called_once_with(
        recipients=[test_email],
        subject="FoodiniApp email verification",
        body=f"Please click this link: http://localhost:8000/v1/users/confirm/new-account?url_token={test_token} "
        f"to verify your email.",
        subtype=MessageType.html,
    )
    mock_mail_service.send_message.assert_called_once()


@pytest.mark.asyncio
async def test_send_password_reset_verification(email_verification_service, mock_mail_service):
    test_form_url = "https://example.com/reset"
    expected_link = f"{test_form_url}/?token={test_token}"
    expected_body = f"To change the password please click this link: {expected_link}."
    email_verification_service.templates = MagicMock()
    email_verification_service.templates.get_template.return_value.render.return_value = expected_body

    await email_verification_service.send_password_reset_verification(test_email, test_form_url, test_token)

    mock_mail_service.build_message.assert_called_once_with(
        recipients=[test_email],
        subject="FoodiniApp new password request",
        body=expected_body,
        subtype=MessageType.html,
    )
    mock_mail_service.send_message.assert_called_once()


@pytest.mark.asyncio
async def test_process_new_account_verification_new_user(
    email_verification_service, mock_user_repository, mock_mail_service
):
    expected_body = (
        f"Please click this link: {config.API_URL}/v1/users/confirm/new-account?url_token={test_token}"
        f" to verify your email."
    )
    message_to_send = MessageSchema(
        recipients=[test_email],
        subject="FoodiniApp email verification",
        body=expected_body,
        subtype=MessageType.html,
    )
    mock_user_repository.get_user_by_email = AsyncMock(return_value=None)
    email_verification_service.templates = MagicMock()
    email_verification_service.templates.get_template.return_value.render.return_value = expected_body
    mock_mail_service.build_message.return_value = message_to_send

    await email_verification_service.process_new_account_verification(test_email, test_token)

    mock_mail_service.send_message.assert_called_once_with(message_to_send)


@pytest.mark.asyncio
async def test_process_new_account_verification_already_verified(email_verification_service, mock_user_validators):
    mock_user = AsyncMock()
    mock_user.is_verified = True
    mock_user_validators.ensure_user_exists_by_email = AsyncMock()

    with pytest.raises(HTTPException) as exc_info:
        await email_verification_service.process_new_account_verification(test_email, test_token)

    assert exc_info.value.status_code == status.HTTP_400_BAD_REQUEST
    assert "already verified" in exc_info.value.detail


@pytest.mark.asyncio
async def test_process_password_reset_verification(email_verification_service, mock_user_validators, mock_mail_service):
    test_form_url = "https://example.com/reset"
    expected_link = f"{test_form_url}/?token={test_token}"
    expected_body = f"To change the password please click this link: {expected_link}."
    message_to_send = MessageSchema(
        recipients=[test_email],
        subject="FoodiniApp email verification",
        body=expected_body,
        subtype=MessageType.html,
    )
    email_verification_service.templates = MagicMock()
    email_verification_service.templates.get_template.return_value.render.return_value = expected_body
    mock_mail_service.build_message.return_value = message_to_send

    await email_verification_service.process_password_reset_verification(test_email, test_form_url, test_token)

    mock_user_validators.ensure_user_exists_by_email.assert_called_once_with(test_email)
    mock_mail_service.send_message.assert_called_once_with(message_to_send)


@pytest.mark.asyncio
async def test_resend_verification(email_verification_service, mock_user_validators, mock_mail_service):
    form_url = "1.1.1.1:3000"
    expected_body = (
        f"Please click this link: {form_url}/v1/users/confirm/new-account?url_token={test_token} to verify your email."
    )
    message_to_send = MessageSchema(
        recipients=[test_email],
        subject="FoodiniApp email verification",
        body=expected_body,
        subtype=MessageType.html,
    )
    email_verification_service.templates = MagicMock()
    email_verification_service.templates.get_template.return_value.render.return_value = expected_body
    mock_mail_service.build_message.return_value = message_to_send

    await email_verification_service.process_password_reset_verification(test_email, form_url, test_token)

    mock_user_validators.ensure_user_exists_by_email.assert_called_once_with(test_email)
    mock_mail_service.send_message.assert_called_once_with(message_to_send)
