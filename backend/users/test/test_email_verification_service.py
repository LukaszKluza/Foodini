import pytest
from fastapi import HTTPException, status
from unittest.mock import AsyncMock, MagicMock, patch

from backend.users.service.email_verification_sevice import EmailVerificationService
from backend.mail import MailService
from backend.settings import config
from backend.core.user_authorisation_service import AuthorizationService


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
def email_verification_service(mock_user_repository, mock_user_validators):
    return EmailVerificationService(
        user_repository=mock_user_repository, user_validators=mock_user_validators
    )


@pytest.fixture
def patch_mail_create_send():
    with (
        patch.object(
            MailService, "create_message", new_callable=AsyncMock
        ) as mock_create,
        patch.object(MailService, "send_message", new_callable=AsyncMock) as mock_send,
    ):
        yield mock_create, mock_send


@pytest.fixture
def patch_send_new_account_verification():
    with patch.object(
        EmailVerificationService,
        "send_new_account_verification",
        new_callable=AsyncMock,
    ) as mock_send:
        yield mock_send


@pytest.fixture
def patch_send_password_reset_verification():
    with patch.object(
        EmailVerificationService,
        "send_password_reset_verification",
        new_callable=AsyncMock,
    ) as mock_send:
        yield mock_send


@pytest.fixture
def patch_authorization_token():
    with patch.object(
        AuthorizationService, "create_url_safe_token", new_callable=AsyncMock
    ) as mock_token:
        yield mock_token


@pytest.fixture
def patch_process_new_account_verification():
    with patch.object(
        EmailVerificationService,
        "process_new_account_verification",
        new_callable=AsyncMock,
    ) as mock_process:
        yield mock_process


@pytest.mark.asyncio
async def test_send_new_account_verification(
    email_verification_service, patch_mail_create_send
):
    test_email = "test@example.com"
    test_token = "test_token"
    mock_create, mock_send = patch_mail_create_send

    await email_verification_service.send_new_account_verification(
        test_email, test_token
    )

    mock_create.assert_called_once_with(
        recipients=[test_email],
        subject="FoodiniApp email verification",
        body=f"Please click this link: {config.API_URL}/v1/users/confirm/new-account?url_token={test_token} to verify your email.",
    )
    mock_send.assert_called_once()


@pytest.mark.asyncio
async def test_send_password_reset_verification(
    email_verification_service, patch_mail_create_send
):
    test_email = "test@example.com"
    test_form_url = "https://example.com/reset"
    test_token = "mocked_token"
    mock_create, mock_send = patch_mail_create_send

    await email_verification_service.send_password_reset_verification(
        test_email, test_form_url, test_token
    )

    expected_link = f"{test_form_url}/?token={test_token}"
    expected_subject = "FoodiniApp new password request"
    expected_body = f"To change the password please click this link: {expected_link}."

    mock_create.assert_called_once_with(
        recipients=[test_email],
        subject=expected_subject,
        body=expected_body,
    )
    mock_send.assert_called_once()


@pytest.mark.asyncio
async def test_process_new_account_verification_new_user(
    email_verification_service,
    mock_user_repository,
    patch_send_new_account_verification,
):
    test_email = "test@example.com"
    test_token = "test_token"
    mock_user_repository.get_user_by_email = AsyncMock(return_value=None)
    mock_send = patch_send_new_account_verification

    await email_verification_service.process_new_account_verification(
        test_email, test_token
    )

    mock_send.assert_called_once_with(test_email, test_token)


@pytest.mark.asyncio
async def test_process_new_account_verification_already_verified(
    email_verification_service,
):
    test_email = "test@example.com"
    test_token = "test_token"

    mock_user = AsyncMock()
    mock_user.is_verified = True
    mock_user_validators.ensure_user_exists_by_email = AsyncMock()

    with pytest.raises(HTTPException) as exc_info:
        await email_verification_service.process_new_account_verification(
            test_email, test_token
        )

    assert exc_info.value.status_code == status.HTTP_400_BAD_REQUEST
    assert "already verified" in exc_info.value.detail


@pytest.mark.asyncio
async def test_process_password_reset_verification(
    email_verification_service,
    mock_user_validators,
    patch_send_password_reset_verification,
):
    test_email = "test@example.com"
    test_form_url = "https://example.com/reset"
    test_token = "test_token"
    mock_send = patch_send_password_reset_verification

    await email_verification_service.process_password_reset_verification(
        test_email, test_form_url, test_token
    )

    mock_user_validators.ensure_user_exists_by_email.assert_called_once_with(test_email)
    mock_send.assert_called_once_with(test_email, test_form_url, test_token)


@pytest.mark.asyncio
async def test_resend_verification(
    email_verification_service,
    mock_user_validators,
    patch_authorization_token,
    patch_process_new_account_verification,
):
    test_email = "test@example.com"
    test_token = "generated_token"

    mock_token = patch_authorization_token
    mock_token.return_value = test_token
    mock_process = patch_process_new_account_verification

    await email_verification_service.resend_verification(test_email)

    mock_user_validators.ensure_user_exists_by_email.assert_called_once_with(test_email)
    mock_token.assert_called_once_with({"email": test_email})
    mock_process.assert_called_once_with(test_email, test_token)


@pytest.mark.asyncio
async def test_get_email_verification_service():
    mock_repo = MagicMock()
    mock_validators = MagicMock()

    service = EmailVerificationService(
        user_repository=mock_repo, user_validators=mock_validators
    )

    assert service.user_repository == mock_repo
    assert service.user_validators == mock_validators
