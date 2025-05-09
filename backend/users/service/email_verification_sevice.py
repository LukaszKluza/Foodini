from pydantic import EmailStr
from fastapi import HTTPException, status
from fastapi.params import Depends

from backend.mail import MailService
from backend.settings import config
from backend.users.service.user_authorisation_service import AuthorizationService
from backend.users.user_repository import UserRepository, get_user_repository
from backend.users.service.user_validation_service import (
    UserValidationService,
    get_user_validators,
)


class EmailVerificationService:
    def __init__(
        self,
        user_repository: UserRepository = Depends(get_user_repository),
        user_validators: UserValidationService = Depends(get_user_validators),
    ):
        self.user_repository = user_repository
        self.user_validators = user_validators

    async def send_new_account_verification(self, email: EmailStr, token: str):
        message_link = f"{config.API_URL}/v1/users/confirm/new-account/{token}"
        message_subject = "FoodiniApp email verification"
        message_body = f"Please click this link: {message_link} to verify your email."

        message = await MailService.create_message(
            recipients=[email], subject=message_subject, body=message_body
        )
        await MailService.send_message(message)

    async def send_password_reset_verification(
        self, email: EmailStr, form_url: str
    ):
        message_link = f"{form_url}"
        message_subject = "FoodiniApp new password request"
        message_body = f"To change the password please click this link: {message_link}."

        message = await MailService.create_message(
            recipients=[email], subject=message_subject, body=message_body
        )
        await MailService.send_message(message)

    async def process_new_account_verification(self, email: EmailStr, token: str):
        user = await self.user_repository.get_user_by_email(email)
        if user and user.is_verified:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="User is already verified",
            )
        await self.send_new_account_verification(email, token)

    async def process_password_reset_verification(
        self, email: EmailStr, form_url: str
    ):
        await self.user_validators.ensure_user_exists_by_email(email)
        await self.send_password_reset_verification(email, form_url)

    async def resend_verification(self, email: EmailStr):
        await self.user_validators.ensure_user_exists_by_email(email)
        token = await AuthorizationService.create_url_safe_token({"email": email})
        await self.process_new_account_verification(email, token)


def get_email_verification_service(
    user_repository: UserRepository = Depends(get_user_repository),
    user_validators: UserValidationService = Depends(get_user_validators),
) -> EmailVerificationService:
    return EmailVerificationService(user_repository, user_validators)
