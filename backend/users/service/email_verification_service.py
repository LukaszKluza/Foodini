from fastapi import HTTPException, status
from fastapi_mail import MessageType
from pydantic import EmailStr
from starlette.templating import Jinja2Templates

from backend.core.user_authorisation_service import AuthorizationService
from backend.settings import config
from backend.users.mail import MailService
from backend.users.service.user_validation_service import (
    UserValidationService,
)
from backend.users.user_repository import UserRepository


class EmailVerificationService:
    def __init__(
        self,
        user_repository: UserRepository,
        user_validators: UserValidationService,
        mail_service: MailService,
        authorization_service: AuthorizationService,
    ):
        self.user_repository = user_repository
        self.user_validators = user_validators
        self.mail_service = mail_service
        self.authorization_service = authorization_service
        self.templates = Jinja2Templates(directory="backend/users/templates")

    async def send_password_reset_verification(self, email: EmailStr, form_url: str, token: str):
        message_link = f"{form_url}/?token={token}"
        message_subject = "FoodiniApp new password request"
        message_body = self.templates.get_template("confirmation_template.html").render(
            header="Welcome to FoodiniApp!",
            message="To change the password please click this link:",
            message_link=message_link,
        )

        message = await self.mail_service.build_message(
            recipients=[email],
            subject=message_subject,
            body=message_body,
            subtype=MessageType.html,
        )

        await self.mail_service.send_message(message)

    async def process_new_account_verification(self, email: EmailStr, token: str):
        user = await self.user_repository.get_user_by_email(email)
        if user and user.is_verified:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="User is already verified",
            )
        await self._send_new_account_verification(email, token)

    async def process_password_reset_verification(self, email: EmailStr, form_url: str, token: str):
        await self.user_validators.ensure_user_exists_by_email(email)
        await self.send_password_reset_verification(email, form_url, token)

    async def resend_verification(self, email: EmailStr):
        if email is None:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Email is required",
            )
        user = await self.user_validators.ensure_user_exists_by_email(email)
        token = await self.authorization_service.create_url_safe_token(
            {"email": email, "language": user.language.value}
        )
        await self.process_new_account_verification(email, token)

    async def _send_new_account_verification(self, email: EmailStr, token: str):
        message_link = f"{config.API_URL}/v1/users/confirm/new-account?url_token={token}"
        message_subject = "FoodiniApp email verification"
        message_body = self.templates.get_template("confirmation_template.html").render(
            header="Welcome to FoodiniApp!",
            message="Please click the button below to verify your email address:",
            message_link=message_link,
        )

        message = await self.mail_service.build_message(
            recipients=[email],
            subject=message_subject,
            body=message_body,
            subtype=MessageType.html,
        )
        await self.mail_service.send_message(message)
