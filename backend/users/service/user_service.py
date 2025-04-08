from datetime import datetime
from fastapi import HTTPException, status
from fastapi.params import Depends

from backend.users.service.authorisation_service import AuthorizationService
from backend.users.service.email_verification_sevice import (
    EmailVerificationService,
    get_email_verification_service,
)
from backend.users.service.password_service import PasswordService
from backend.users.user_decorators import UserDecorators
from backend.users.schemas import (
    UserCreate,
    UserLogin,
    UserUpdate,
    LoginUserResponse,
    PasswordResetRequest,
    NewPasswordConfirm,
)
from backend.users.models import User
from backend.users.user_repository import UserRepository, get_user_repository
from backend.settings import config


class UserService:
    def __init__(
        self,
        user_repository: UserRepository = Depends(get_user_repository),
        email_verification_service: EmailVerificationService = Depends(
            get_email_verification_service
        ),
    ):
        self.user_repository = user_repository
        self.email_verification_service = email_verification_service

    async def register(self, user: UserCreate):
        existing_user = await self.user_repository.get_user_by_email(user.email)
        if existing_user:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="User already exists",
            )
        user.password = await PasswordService.hash_password(user.password)

        token = await AuthorizationService.create_url_safe_token({"email": user.email})

        await self.email_verification_service.process_new_account_verification(
            user.email, token
        )
        return await self.user_repository.create_user(user)

    @UserDecorators.inject_user_by_email(email_arg_index=0)
    @UserDecorators.requires_verified_user(user_arg_index=1)
    async def login(self, user_login: UserLogin, user_: User):
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

    @UserDecorators.inject_user_by_id(user_id_index=1)
    async def logout(self, _: User, user_id: int):
        await AuthorizationService.delete_user_token(user_id)
        return HTTPException(status_code=status.HTTP_200_OK, detail="Logged out")

    @UserDecorators.inject_user_by_email(email_arg_index=0)
    @UserDecorators.requires_verified_user(user_arg_index=2)
    # @UserDecorators.requires_permission(request_id_index=1, token_id_index=2) TODO: think about new logic for this
    @UserDecorators.requires_password_change_allowed(user_arg_index=2)
    async def reset_password(
        self, password_reset_request: PasswordResetRequest, form_url: str, user_: User
    ):
        user_id_from_token = None
        if password_reset_request.token:
            try:
                payload = await AuthorizationService.verify_token(
                    password_reset_request.token
                )
                user_id_from_token = payload.get("id")
                if not user_id_from_token:
                    raise HTTPException(
                        status_code=status.HTTP_400_BAD_REQUEST,
                        detail="Invalid token - missing user ID",
                    )

                await AuthorizationService.delete_user_token(user_id_from_token)
            except Exception as e:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST, detail="Invalid token"
                ) from e

        reset_token = await AuthorizationService.create_url_safe_token(
            {"email": user_.email, "id": user_.id}, salt=config.NEW_PASSWORD_SALT
        )

        await self.email_verification_service.process_password_reset_verification(
            user_.email, reset_token, form_url
        )

    @UserDecorators.requires_permission(token_id_index=0, request_id_index=1)
    @UserDecorators.inject_user_by_id(user_id_index=1)
    async def update(
        self,
        user_id_from_token: int,
        user_id_from_request: int,
        user: UserUpdate,
        user_: User,
    ):
        return await self.user_repository.update_user(user_.id, user)

    @UserDecorators.requires_permission(token_id_index=0, request_id_index=1)
    @UserDecorators.inject_user_by_id(user_id_index=1)
    async def delete(self, user_id_from_token: int, user_id_from_request: int, _: User):
        await AuthorizationService.delete_user_token(user_id_from_request)
        return await self.user_repository.delete_user(user_id_from_request)

    @UserDecorators.inject_user_by_token()
    # @UserDecorators.requires_permission(token_id_index=1, request_id_index=2)
    async def confirm_new_password(
        self, token: str, new_password_confirm: NewPasswordConfirm, user_: User
    ):
        hashed_password = await PasswordService.hash_password(
            new_password_confirm.password
        )
        return await self.user_repository.update_password(
            user_.id, hashed_password, datetime.now(config.TIMEZONE)
        )

    @UserDecorators.inject_user_by_token()
    async def confirm_new_account(self, token: str, user_: User):
        return await self.user_repository.verify_user(user_.email)


def get_user_service(
    user_repository: UserRepository = Depends(get_user_repository),
    email_verification_service: EmailVerificationService = Depends(
        get_email_verification_service
    ),
) -> UserService:
    return UserService(user_repository, email_verification_service)
