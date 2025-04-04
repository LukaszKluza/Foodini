from datetime import datetime
from fastapi import HTTPException, status
from fastapi.params import Depends
from pydantic import EmailStr

from backend.users.models import User
from backend.users.service.authorisation_service import AuthorizationService
from backend.users.service.password_service import PasswordService
from backend.users.schemas import (
    UserCreate,
    UserLogin,
    UserUpdate,
    LoginUserResponse,
    PasswordResetRequest,
)
from backend.users.user_repository import UserRepository, get_user_repository
from backend.mail import MailService
from backend.Settings import config


async def check_user_permission(
    user_param_from_token: int, user_param_from_request: int
):
    if user_param_from_token != user_param_from_request:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN, detail="Invalid token"
        )


async def send_new_account_verification_message(email: EmailStr, token: str):
    message_link = f"{config.API_URL}/v1/users/confirm/new-account/{token}"
    message_subject = "FoodiniApp email verification"
    message_body = f"Please click this link: {message_link} to verify your email."

    message = await MailService.create_message(
        recipients=[email], subject=message_subject, body=message_body
    )

    await MailService.send_message(message)


async def send_new_password_verification_message(
    email: EmailStr, token: str, form_url: str
):
    message_link = f"{form_url}/{token}"
    message_subject = "FoodiniApp new password request"
    message_body = f"To change the password please click this link: {message_link}."

    message = await MailService.create_message(
        recipients=[email], subject=message_subject, body=message_body
    )

    await MailService.send_message(message)


async def ensure_verified_user(user):
    if not user.is_verified:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Account not verified. Please check your email for verification link.",
        )
    return user


async def check_last_password_change_data_time(user):
    time_diff  = (datetime.now(config.TIMEZONE) - user.last_password_update).total_seconds()
    if time_diff < config.RESET_PASSWORD_OFFSET_SECONDS:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail=f"You must wait at least 1 day before changing your password again,"
                   f" last changed {user.last_password_update}",
        )


class UserService:
    def __init__(self, user_repository: UserRepository = Depends(get_user_repository)):
        self.user_repository = user_repository

    async def register(self, user: UserCreate):
        existing_user = await self.user_repository.get_user_by_email(user.email)
        if existing_user:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="User already exists",
            )
        user.password = await PasswordService.hash_password(user.password)

        token = await AuthorizationService.create_url_safe_token(
            {"email": user.email}
        )

        await self.process_new_account_verification_message(user.email, token)
        return await self.user_repository.create_user(user)


    async def login(self, user_login: UserLogin):
        user_ = await self.ensure_user_exists_by_email(user_login.email)
        await ensure_verified_user(user_)

        if not await PasswordService.verify_password(
            user_login.password, user_.password
        ):
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Incorrect password",
            )

        access_token, refresh_token = await AuthorizationService.create_tokens(
            {"sub": user_.email, "id": user_.id}
        )

        return LoginUserResponse(
            id=user_.id,
            email=user_.email,
            access_token=access_token,
            refresh_token=refresh_token,
        )

    async def logout(self, user_id: int):
        await self.ensure_user_exists_by_id(user_id)

        await AuthorizationService.delete_user_token(user_id)
        return HTTPException(status_code=status.HTTP_200_OK, detail="Logged out")

    async def reset_password(
        self, password_reset_request: PasswordResetRequest, form_url: str
    ):
        user_ = await self.ensure_user_exists_by_email(password_reset_request.email)
        await ensure_verified_user(user_)
        user_id_from_request = password_reset_request.id

        if user_id_from_request:
            await check_user_permission(user_.id, user_id_from_request)
            await AuthorizationService.delete_user_token(user_id_from_request)

        print(user_)
        await check_last_password_change_data_time(user_)

        token = await AuthorizationService.create_url_safe_token(
            {"email": user_.email}, salt=config.NEW_PASSWORD_SALT
        )

        await self.process_new_password_verification_message(
            user_.email, token, form_url
        )

    async def update(
        self, user_id_from_token: int, user_id_from_request, user: UserUpdate
    ):
        await check_user_permission(user_id_from_token, user_id_from_request)
        user_ = await self.ensure_user_exists_by_id(user_id_from_request)

        return await self.user_repository.update_user(user_.id, user)

    async def delete(self, user_id_from_token: int, user_id_from_request: int):
        await check_user_permission(user_id_from_token, user_id_from_request)
        await self.ensure_user_exists_by_id(user_id_from_request)

        await AuthorizationService.delete_user_token(user_id_from_request)
        return await self.user_repository.delete_user(user_id_from_request)

    async def decode_url_token(self, token: str, salt: str = config.NEW_ACCOUNT_SALT):
        token_data = await AuthorizationService.decode_url_safe_token(token, salt)
        user_email = token_data.get("email")
        await self.ensure_user_exists_by_email(user_email)

        return user_email

    async def process_new_account_verification_message(
        self, email: EmailStr, token: str
    ):
        user_ = await self.user_repository.get_user_by_email(email)

        if user_ and user_.is_verified:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="User is already verified",
            )

        await send_new_account_verification_message(email, token)

    async def process_new_password_verification_message(
        self, email: EmailStr, token: str, form_url: str
    ):
        await self.ensure_user_exists_by_email(email)
        await send_new_password_verification_message(email, token, form_url)

    async def confirm_new_password(self, token, new_password_confirm):
        user_email_from_token = await self.decode_url_token(
            token, salt=config.NEW_PASSWORD_SALT
        )
        await check_user_permission(user_email_from_token, new_password_confirm.email)
        user_ = await self.ensure_user_exists_by_email(user_email_from_token)

        hashed_password = await PasswordService.hash_password(
            new_password_confirm.password
        )
        return await self.user_repository.update_password(user_.id, hashed_password, datetime.now(config.TIMEZONE))

    async def ensure_user_exists_by_email(self, user_email) -> User:
        existing_user = await self.user_repository.get_user_by_email(user_email)
        if not existing_user:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="User does not exist",
            )

        return existing_user

    async def ensure_user_exists_by_id(self, user_id) -> User:
        existing_user = await self.user_repository.get_user_by_id(user_id)
        if not existing_user:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="User does not exist",
            )

        return existing_user

    async def confirm_new_account(self, token: str):
        user_email = await self.decode_url_token(token)
        return await self.user_repository.verify_user(user_email)

    async def resend_verification(self, email: EmailStr):
        await self.ensure_user_exists_by_email(email)

        token = await AuthorizationService.create_url_safe_token({"email": email})

        await self.process_new_account_verification_message(email, token)


def get_user_service(
    user_repository: UserRepository = Depends(get_user_repository),
) -> UserService:
    return UserService(user_repository)
