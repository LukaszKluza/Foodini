from fastapi import HTTPException, status
from fastapi.params import Depends
from watchfiles import awatch

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
from backend.mail import mail, create_message
from backend.Settings import config


async def check_user_permission(
    user_param_from_token: int, user_param_from_request: int
):
    if user_param_from_token != user_param_from_request:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN, detail="Invalid token"
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
        new_user = await self.user_repository.create_user(user)

        token = await AuthorizationService.create_url_safe_token(
            {"email": new_user.email}
        )
        message_link = f"{config.API_URL}/v1/users/confirm/new-account/{token}"

        await self.send_verification_message(new_user.email, message_link)
        return new_user

    async def login(self, user_login: UserLogin):
        user_ = await self.ensure_user_exists_by_email(user_login.email)

        if not user_.is_verified:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Account not verified. Please check your email for verification link.",
            )

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

    async def reset_password(self, password_reset_request: PasswordResetRequest):
        user_ = await self.ensure_user_exists_by_email(password_reset_request.email)
        user_id_from_request = password_reset_request.id

        if user_id_from_request:
            if user_.id != user_id_from_request:
                raise HTTPException(
                    status_code=status.HTTP_403_FORBIDDEN,
                    detail="Unauthorized access to reset password",
                )
            else:
                await AuthorizationService.delete_user_token(user_id_from_request)

        token = await AuthorizationService.create_url_safe_token({"email": user_.email})
        message_link = f"{config.API_URL}/v1/users/confirm/new-password/{token}"

        await self.send_verification_message(user_.email, message_link)

    async def update(
        self, user_id_from_token: int, user_id_from_request, user: UserUpdate
    ):
        await check_user_permission(user_id_from_token, user_id_from_request)
        user_ = await self.ensure_user_exists_by_id(user_id_from_request)

        return await self.user_repository.update_user(user_.id, user)

    async def delete(self, user_id_from_token: int, user_id_from_request: int):
        await check_user_permission(user_id_from_token, user_id_from_request)
        user_ = await self.user_repository.get_user_by_id(user_id_from_request)
        if not user_:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="User with this ID does not exist",
            )

        await AuthorizationService.delete_user_token(user_id_from_request)
        return await self.user_repository.delete_user(user_id_from_request)

    async def decode_url_token(self, token: str):
        token_data = await AuthorizationService.decode_url_safe_token(token)
        user_email = token_data.get("email")
        user_ = await self.user_repository.get_user_by_email(user_email)
        if not user_:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="User with this Email does not exist",
            )

        return user_email

    async def send_verification_message(self, email: str, message_link):
        user_ = await self.ensure_user_exists_by_email(email)

        if user_.is_verified:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="User is already verified",
            )

        message_subject = "FoodiniApp email verification"
        message_body = f"Please click this {message_link} to verify your email"

        message = create_message(
            recipients=[email], subject=message_subject, body=message_body
        )

        await mail.send_message(message)

    async def confirm_new_password(self, token: str, new_password_confirm):
        user_email_from_token = await self.decode_url_token(token)
        await check_user_permission(user_email_from_token, new_password_confirm.email)
        user_ = await self.ensure_user_exists_by_email(user_email_from_token)

        return await self.user_repository.update_password(
            user_.id, new_password_confirm.password
        )

    async def ensure_user_exists_by_email(self, user_email):
        existing_user = await self.user_repository.get_user_by_email(user_email)
        if not existing_user:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="User does not exist",
            )

        return existing_user

    async def ensure_user_exists_by_id(self, user_id):
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


def get_user_service(
    user_repository: UserRepository = Depends(get_user_repository),
) -> UserService:
    return UserService(user_repository)
