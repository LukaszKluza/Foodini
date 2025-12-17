from typing import Optional

from fastapi import APIRouter, Depends, status
from fastapi.params import Query
from fastapi.security import OAuth2PasswordBearer
from pydantic import EmailStr

from backend.settings import config
from backend.users.service.email_verification_service import (
    EmailVerificationService,
)
from backend.users.service.user_service import UserService

from ..core.role_sets import user_or_admin
from .auth_dependencies import AuthDependency
from .dependencies import (
    get_auth_dependency,
    get_email_verification_service,
    get_user_service,
)
from .schemas import (
    ChangeLanguageRequest,
    DefaultResponse,
    LoginUserResponse,
    NewPasswordConfirm,
    PasswordResetRequest,
    UserCreate,
    UserLogin,
    UserResponse,
    UserUpdate,
)

user_router = APIRouter(prefix="/v1/users", tags=["User", "Admin"])

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/v1/users/login")


@user_router.get(
    "/",
    response_model=UserResponse,
    summary="Get current user profile",
    description="Retrieves the profile information of the currently authenticated user.",
    dependencies=[user_or_admin],
)
async def get_user(
    auth_dependency: AuthDependency = Depends(get_auth_dependency),
):
    user, _ = await auth_dependency.get_current_user()
    return user


@user_router.post(
    "/",
    response_model=DefaultResponse,
    summary="Register new user",
    description="Creates a new user account with the provided information and sends a verification email.",
)
async def register_user(user: UserCreate, user_service: UserService = Depends(get_user_service)):
    return await user_service.register(user)


@user_router.patch(
    "/",
    response_model=DefaultResponse,
    summary="Update user profile",
    description="Updates the profile information of the currently authenticated user with the provided data.",
    dependencies=[user_or_admin],
)
async def update_user(
    user_update: UserUpdate,
    user_service: UserService = Depends(get_user_service),
    auth_dependency: AuthDependency = Depends(get_auth_dependency),
):
    user, _ = await auth_dependency.get_current_user()
    return await user_service.update(user, user_update)


@user_router.delete(
    "/",
    status_code=status.HTTP_204_NO_CONTENT,
    summary="Delete user account",
    description="Permanently deletes the currently authenticated user's account and all associated data.",
    dependencies=[user_or_admin],
)
async def delete_user(
    user_service: UserService = Depends(get_user_service),
    auth_dependency: AuthDependency = Depends(get_auth_dependency),
):
    user, token_payload = await auth_dependency.get_current_user()
    return await user_service.delete(user, token_payload)


@user_router.post(
    "/login",
    response_model=LoginUserResponse,
    summary="User login",
    description="Authenticates a user with email and password, returning access and refresh "
    "tokens upon successful login.",
)
async def login_user(user: UserLogin, user_service: UserService = Depends(get_user_service)):
    return await user_service.login(user)


@user_router.get(
    "/logout",
    status_code=status.HTTP_204_NO_CONTENT,
    summary="User logout",
    description="Logs out the currently authenticated user by invalidating their access token.",
    dependencies=[user_or_admin],
)
async def logout_user(
    user_service: UserService = Depends(get_user_service),
    auth_dependency: AuthDependency = Depends(get_auth_dependency),
):
    _, token_payload = await auth_dependency.get_current_user()
    return await user_service.logout(token_payload)


@user_router.post(
    "/refresh-tokens",
    status_code=status.HTTP_200_OK,
    summary="Refresh authentication tokens",
    description="Generates new access and refresh tokens using a valid refresh token.",
)
async def refresh_tokens(
    auth_dependency: AuthDependency = Depends(get_auth_dependency),
):
    return await auth_dependency.get_refreshed_tokens()


@user_router.post(
    "/reset-password/request",
    response_model=DefaultResponse,
    summary="Request password reset",
    description="Initiates the password reset process by sending a reset link to the user's email address.",
)
async def reset_password(
    password_reset_request: PasswordResetRequest,
    form_url: Optional[str] = f"{config.FRONTEND_URL}/#/change_password",
    user_service: UserService = Depends(get_user_service),
):
    return await user_service.reset_password(password_reset_request, form_url)


@user_router.patch(
    "/language",
    response_model=UserResponse,
    summary="Update user language",
    description="Changes the language setting for the currently authenticated user.",
    dependencies=[user_or_admin],
)
async def update_language(
    request: ChangeLanguageRequest,
    user_service: UserService = Depends(get_user_service),
    auth_dependency: AuthDependency = Depends(get_auth_dependency),
):
    user, _ = await auth_dependency.get_current_user()
    return await user_service.change_language(user, request)


@user_router.post(
    "/confirm/new-password",
    response_model=DefaultResponse,
    summary="Confirm new password",
    description="Completes the password reset process by verifying the reset token and setting the new password.",
)
async def verify_new_password(
    new_password_confirm: NewPasswordConfirm,
    user_service: UserService = Depends(get_user_service),
):
    return await user_service.confirm_new_password(new_password_confirm)


@user_router.get(
    "/confirm/new-account",
    response_model=DefaultResponse,
    summary="Verify new account",
    description="Activates a newly registered account by validating the verification token sent to their email.",
)
async def verify_new_account(url_token: str = Query(None), user_service: UserService = Depends(get_user_service)):
    return await user_service.confirm_new_account(url_token)


@user_router.get(
    "/confirm/resend-verification-new-account",
    status_code=status.HTTP_204_NO_CONTENT,
    summary="Resend account verification email",
    description="Sends a new verification email with a fresh token to the specified email address "
    "for account activation.",
)
async def resend_verification(
    email: Optional[EmailStr] = None,
    email_verification_service: EmailVerificationService = Depends(get_email_verification_service),
):
    return await email_verification_service.resend_verification(email)
