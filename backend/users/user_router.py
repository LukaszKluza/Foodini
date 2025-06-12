from typing import Optional

from fastapi import APIRouter, Depends, status
from fastapi.params import Query
from fastapi.security import OAuth2PasswordBearer
from pydantic import EmailStr

from backend.settings import config
from backend.users.service.email_verification_sevice import (
    EmailVerificationService,
)
from backend.users.service.user_service import UserService
from .auth_dependencies import AuthDependency
from .dependencies import get_user_service, get_email_verification_service
from .schemas import (
    UserCreate,
    DefaultResponse,
    UserUpdate,
    UserLogin,
    LoginUserResponse,
    PasswordResetRequest,
    NewPasswordConfirm,
    UserResponse,
    ChangeLanguageRequest,
)
from ..models import User

user_router = APIRouter(prefix="/v1/users")

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/v1/users/login")


@user_router.get("/", response_model=UserResponse)
async def get_user(
    user_token: tuple[User, dict] = Depends(AuthDependency().get_current_user),
):
    return user_token[0]


@user_router.post("/", response_model=DefaultResponse)
async def register_user(
    user: UserCreate, user_service: UserService = Depends(get_user_service)
):
    return await user_service.register(user)


@user_router.patch("/", response_model=DefaultResponse)
async def update_user(
    user_update: UserUpdate,
    user_service: UserService = Depends(get_user_service),
    user_token: tuple[User, dict] = Depends(AuthDependency().get_current_user),
):
    user, token_payload = user_token
    return await user_service.update(user, user_update)


@user_router.delete("/", status_code=status.HTTP_204_NO_CONTENT)
async def delete_user(
    user_service: UserService = Depends(get_user_service),
    user_token: tuple[User, dict] = Depends(AuthDependency().get_current_user),
):
    user, token_payload = user_token
    return await user_service.delete(user, token_payload)


@user_router.post("/login", response_model=LoginUserResponse)
async def login_user(
    user: UserLogin, user_service: UserService = Depends(get_user_service)
):
    return await user_service.login(user)


@user_router.get("/logout", status_code=status.HTTP_204_NO_CONTENT)
async def logout_user(
    user_service: UserService = Depends(get_user_service),
    user_token: tuple[User, dict] = Depends(AuthDependency().get_current_user),
):
    _, token_payload = user_token
    return await user_service.logout(token_payload)


@user_router.post("/refresh-tokens")
async def refresh_tokens(
    tokens: dict = Depends(AuthDependency().get_refreshed_tokens),
):
    return tokens


@user_router.post("/reset-password/request", response_model=DefaultResponse)
async def reset_password(
    password_reset_request: PasswordResetRequest,
    form_url: Optional[str] = f"{config.FRONTEND_URL}/#/change_password",
    user_service: UserService = Depends(get_user_service),
):
    return await user_service.reset_password(password_reset_request, form_url)


@user_router.patch("/language", response_model=UserResponse)
async def update_language(
    request: ChangeLanguageRequest,
    user_service: UserService = Depends(get_user_service),
    user_token: tuple[User, dict] = Depends(AuthDependency().get_current_user),
):
    user, _ = user_token
    return await user_service.change_language(user, request)


@user_router.post("/confirm/new-password", response_model=DefaultResponse)
async def verify_new_password(
    new_password_confirm: NewPasswordConfirm,
    user_service: UserService = Depends(get_user_service),
):
    return await user_service.confirm_new_password(new_password_confirm)


@user_router.get("/confirm/new-account", response_model=DefaultResponse)
async def verify_new_account(
    url_token: str = Query(None), user_service: UserService = Depends(get_user_service)
):
    return await user_service.confirm_new_account(url_token)


@user_router.get(
    "/confirm/resend-verification-new-account", status_code=status.HTTP_204_NO_CONTENT
)
async def resend_verification(
    email: Optional[EmailStr] = None,
    email_verification_service: EmailVerificationService = Depends(
        get_email_verification_service
    ),
):
    return await email_verification_service.resend_verification(email)
