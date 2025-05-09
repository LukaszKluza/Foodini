from datetime import datetime
from fastapi import HTTPException, status
from fastapi.params import Depends

from backend.users.service.user_authorisation_service import AuthorizationService
from backend.users.service.email_verification_sevice import (
    EmailVerificationService,
    get_email_verification_service,
)
from backend.users.service.password_service import PasswordService
from backend.users.service.user_validation_service import (
    UserValidationService,
    get_user_validators,
)
from backend.users.schemas import (
    UserCreate,
    UserLogin,
    UserUpdate,
    UserResponse,
    LoginUserResponse,
    PasswordResetRequest,
    NewPasswordConfirm,
)
from backend.users.user_repository import UserRepository, get_user_repository
from backend.settings import config


class UserService:
    def __init__(
        self,
        user_repository: UserRepository = Depends(get_user_repository),
        email_verification_service: EmailVerificationService = Depends(
            get_email_verification_service
        ),
        user_validators: UserValidationService = Depends(get_user_validators),
    ):
        self.user_repository = user_repository
        self.email_verification_service = email_verification_service
        self.user_validators = user_validators

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

    async def login(self, user_login: UserLogin):
        user_ = await self.user_validators.ensure_user_exists_by_email(user_login.email)
        self.user_validators.ensure_verified_user(user_)

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

    async def logout(self, token_payload: dict, user_id: int):
        await self.user_validators.ensure_user_exists_by_id(user_id)
        await AuthorizationService.revoke_tokens(
            token_payload["jti"], token_payload["linked_jti"]
        )
        return HTTPException(status_code=status.HTTP_200_OK, detail="Logged out")

    async def reset_password(
        self, password_reset_request: PasswordResetRequest, form_url: str
    ):
        user_ = await self.user_validators.ensure_user_exists_by_email(
            password_reset_request.email
        )
        self.user_validators.ensure_verified_user(user_)

        await self.email_verification_service.process_password_reset_verification(
            user_.email, form_url
        )

        return UserResponse(
            id=user_.id,
            email=user_.email,
        )

    async def update(
        self, token_payload: dict, user_id_from_request: int, user: UserUpdate
    ):
        self.user_validators.check_user_permission(
            token_payload["id"], user_id_from_request
        )
        user_ = await self.user_validators.ensure_user_exists_by_id(
            user_id_from_request
        )
        return await self.user_repository.update_user(user_.id, user)

    async def delete(self, token_payload: dict, user_id_from_request: int):
        self.user_validators.check_user_permission(
            token_payload["id"], user_id_from_request
        )
        await self.user_validators.ensure_user_exists_by_id(user_id_from_request)
        await AuthorizationService.revoke_tokens(
            token_payload["jti"], token_payload["linked_jti"]
        )
        return await self.user_repository.delete_user(user_id_from_request)

    async def decode_url_token(self, token: str, salt: str = config.NEW_ACCOUNT_SALT):
        token_data = await AuthorizationService.decode_url_safe_token(token, salt)
        user_email = token_data.get("email")
        await self.user_validators.ensure_user_exists_by_email(user_email)

        return user_email

    async def confirm_new_password(
        self, new_password_confirm: NewPasswordConfirm
    ):
        user_ = await self.user_validators.ensure_user_exists_by_email(
            new_password_confirm.email
        )
        self.user_validators.ensure_verified_user(user_)

        user_id_from_token = None
        if new_password_confirm.token:
            try:
                payload = await AuthorizationService.verify_access_token(
                    new_password_confirm.token
                )
                user_id_from_token = payload.get("id")
                if not user_id_from_token:
                    raise HTTPException(
                        status_code=status.HTTP_400_BAD_REQUEST,
                        detail="Invalid token - missing user ID",
                    )

                self.user_validators.check_user_permission(user_id_from_token, user_.id)
                await AuthorizationService.revoke_tokens(
                    payload["jti"], payload["linked_jti"]
                )
            except Exception as e:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST, detail="Invalid token"
                ) from e

        token = await AuthorizationService.create_url_safe_token(
            {"email": user_.email, "id": user_.id}, salt=config.NEW_PASSWORD_SALT
        )
        user_email_from_token = await self.decode_url_token(
            token, salt=config.NEW_PASSWORD_SALT
        )
        user_ = await self.user_validators.ensure_user_exists_by_email(
            user_email_from_token
        )
        self.user_validators.check_user_permission(
            user_email_from_token, new_password_confirm.email
        )
        hashed_password = await PasswordService.hash_password(
            new_password_confirm.password
        )
        return await self.user_repository.update_password(
            user_.id, hashed_password, datetime.now(config.TIMEZONE)
        )

    async def confirm_new_account(self, token: str):
        user_email = await self.decode_url_token(token)
        return await self.user_repository.verify_user(user_email)


def get_user_service(
    user_repository: UserRepository = Depends(get_user_repository),
    email_verification_service: EmailVerificationService = Depends(
        get_email_verification_service
    ),
    user_validators: UserValidationService = Depends(get_user_validators),
) -> UserService:
    return UserService(user_repository, email_verification_service, user_validators)
