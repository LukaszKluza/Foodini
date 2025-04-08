from pydantic import EmailStr
from fastapi import HTTPException, status
from fastapi.params import Depends

from backend.mail import MailService
from backend.settings import config
from backend.users.service.authorisation_service import AuthorizationService
from backend.users.user_repository import UserRepository, get_user_repository
from backend.users.user_decorators import UserDecorators
from backend.users.models import User


class EmailVerificationService:
    def __init__(self, user_repository: UserRepository):
        self.user_repository = user_repository

    async def send_new_account_verification(self, email: EmailStr, token: str):
        message_link = f"{config.API_URL}/v1/users/confirm/new-account/{token}"
        message_subject = "FoodiniApp email verification"
        message_body = f"Please click this link: {message_link} to verify your email."

        message = await MailService.create_message(
            recipients=[email], subject=message_subject, body=message_body
        )
        await MailService.send_message(message)

    async def send_password_reset_verification(
        self, email: EmailStr, token: str, form_url: str
    ):
        message_link = f"{form_url}/{token}"
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

    @UserDecorators.inject_user_by_email(email_arg_index=0)
    async def process_password_reset_verification(
        self, email: EmailStr, token: str, form_url: str, _: User
    ):
        await self.send_password_reset_verification(email, token, form_url)

    @UserDecorators.inject_user_by_email(email_arg_index=0)
    async def resend_verification(self, email: EmailStr, _: User):
        token = await AuthorizationService.create_url_safe_token({"email": email})
        await self.process_new_account_verification(email, token)


def get_email_verification_service(
    user_repository: UserRepository = Depends(get_user_repository),
) -> EmailVerificationService:
    return EmailVerificationService(user_repository)
