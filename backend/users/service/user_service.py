from datetime import datetime
from typing import Type

from fastapi import HTTPException, Response, status
from starlette.responses import RedirectResponse

from backend.core.logger import logger
from backend.core.user_authorisation_service import AuthorizationService
from backend.models import User
from backend.settings import config
from backend.users.schemas import (
    ChangeLanguageRequest,
    DefaultResponse,
    LoginUserResponse,
    NewPasswordConfirm,
    PasswordResetRequest,
    UserCreate,
    UserLogin,
    UserUpdate,
)
from backend.users.service.email_verification_service import EmailVerificationService
from backend.users.service.password_service import PasswordService
from backend.users.service.user_validation_service import (
    UserValidationService,
)
from backend.users.user_repository import UserRepository


class UserService:
    def __init__(
        self,
        user_repository: UserRepository,
        email_verification_service: EmailVerificationService,
        user_validators: UserValidationService,
        authorization_service: AuthorizationService,
    ):
        self.user_repository = user_repository
        self.email_verification_service = email_verification_service
        self.user_validators = user_validators
        self.authorization_service = authorization_service

    async def register(self, user: UserCreate):
        existing_user = await self.user_repository.get_user_by_email(user.email)
        if existing_user:
            logger.debug("User already exists with this email")
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="User already exists",
            )
        user.password = await PasswordService.hash_password(user.password)

        token = await self.authorization_service.create_url_safe_token(
            {"email": user.email, "language": user.language.value}
        )

        await self.email_verification_service.process_new_account_verification(user.email, token)
        return await self.user_repository.create_user(user)

    async def login(self, user_login: UserLogin):
        user_ = await self.user_validators.ensure_user_exists_by_email(user_login.email)
        self.user_validators.ensure_verified_user(user_)

        if not await PasswordService.verify_password(user_login.password, user_.password):
            logger.debug("Incorrect password provided for user login")
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Incorrect password",
            )

        access_token, refresh_token = await self.authorization_service.create_tokens(
            {"sub": user_.email, "id": str(user_.id)}
        )

        return LoginUserResponse(
            id=user_.id,
            email=user_.email,
            access_token=access_token,
            refresh_token=refresh_token,
        )

    async def logout(self, token_payload: dict):
        await self.authorization_service.revoke_tokens(token_payload["jti"], token_payload["linked_jti"])
        return Response(status_code=204)

    async def reset_password(self, password_reset_request: PasswordResetRequest, form_url: str):
        user_ = await self.user_validators.ensure_user_exists_by_email(password_reset_request.email)
        self.user_validators.ensure_verified_user(user_)

        self.user_validators.check_last_password_change_data_time(user_)
        token = await self.authorization_service.create_url_safe_token({"email": password_reset_request.email})

        await self.email_verification_service.process_password_reset_verification(user_.email, form_url, token)
        return DefaultResponse(
            id=user_.id,
            email=user_.email,
        )

    async def update(self, user: Type[User], new_user_data: UserUpdate):
        return await self.user_repository.update_user(user.id, new_user_data)

    async def change_language(
        self,
        user: Type[User],
        change_language_request: ChangeLanguageRequest,
    ):
        return await self.user_repository.change_language(user.id, change_language_request.language)

    async def delete(self, user: Type[User], token_payload: dict):
        await self.authorization_service.revoke_tokens(token_payload["jti"], token_payload["linked_jti"])
        return await self.user_repository.delete_user(user.id)

    async def decode_url_token(self, token: str, salt: str = config.NEW_ACCOUNT_SALT):
        token_data = await self.authorization_service.decode_url_safe_token(token, salt)
        user_email = token_data.get("email")
        await self.user_validators.ensure_user_exists_by_email(user_email)

        return user_email

    async def confirm_new_password(self, new_password_confirm: NewPasswordConfirm):
        user_email_from_token = await self.decode_url_token(new_password_confirm.token)

        user_ = await self.user_validators.ensure_user_exists_by_email(user_email_from_token)
        self.user_validators.ensure_verified_user(user_)

        self.user_validators.check_user_permission(user_email_from_token, new_password_confirm.email)

        hashed_password = await PasswordService.hash_password(new_password_confirm.password)

        return await self.user_repository.update_password(user_.id, hashed_password, datetime.now(config.TIMEZONE))

    async def confirm_new_account(self, token: str):
        email = await self.authorization_service.extract_email_from_base64(token)
        language = await self.authorization_service.extract_language_from_base64(token)
        try:
            user_email = await self.decode_url_token(token)
            await self.user_repository.verify_user(user_email)
            redirect_url = f"{config.FRONTEND_URL}/#/login?status=success"
        except (HTTPException, TypeError):
            logger.debug("User verification failed. Redirecting to error page.")
            redirect_url = f"{config.FRONTEND_URL}/#/login?status=error"

        if email:
            redirect_url += f"&email={email}"
        if language:
            redirect_url += f"&language={language}"

        return RedirectResponse(url=redirect_url, status_code=status.HTTP_302_FOUND)
