from typing import Optional

from fastapi import APIRouter, Depends, status
from fastapi.params import Query
from fastapi.security import OAuth2PasswordBearer
from pydantic import EmailStr

from backend.settings import config
from backend.users.service.email_verification_sevice import (
    EmailVerificationService,
    get_email_verification_service,
)
from backend.users.service.user_authorisation_service import AuthorizationService
from backend.users.service.user_service import UserService, get_user_service
from .schemas import (
    UserCreate,
    UserResponse,
    UserUpdate,
    UserLogin,
    LoginUserResponse,
    PasswordResetRequest,
    NewPasswordConfirm,
)

user_router = APIRouter(prefix="/v1/users")

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/v1/users/login")


@user_router.get("/", response_model=UserResponse)
async def get_user(
    user_service: UserService = Depends(get_user_service),
    token_payload: dict = Depends(AuthorizationService.verify_access_token),
):
    return await user_service.get_user(token_payload=token_payload)


@user_router.post("/register", response_model=UserResponse)
async def register_user(
    user: UserCreate, user_service: UserService = Depends(get_user_service)
):
    return await user_service.register(user)


@user_router.post("/login", response_model=LoginUserResponse)
async def login_user(
    user: UserLogin, user_service: UserService = Depends(get_user_service)
):
    return await user_service.login(user)


@user_router.get("/logout", status_code=status.HTTP_204_NO_CONTENT)
async def logout_user(
    user_id: int = Query(...),
    user_service: UserService = Depends(get_user_service),
    token_payload: dict = Depends(AuthorizationService.verify_access_token),
):
    return await user_service.logout(
        token_payload=token_payload, user_id_from_request=user_id
    )


@user_router.post("/refresh-tokens")
async def refresh_tokens(
    tokens: dict = Depends(AuthorizationService.refresh_access_token),
):
    return {
        "access_token": tokens["access_token"],
        "refresh_token": tokens["refresh_token"],
    }


@user_router.post("/reset-password/request", status_code=status.HTTP_204_NO_CONTENT)
async def reset_password(
    password_reset_request: PasswordResetRequest,
    form_url: Optional[str] = f"{config.API_URL}/v1/users/confirm/new-password",
    user_service: UserService = Depends(get_user_service),
):
    return await user_service.reset_password(password_reset_request, form_url)


@user_router.patch("/update/{user_id}", response_model=UserResponse)
async def update_user(
    user_id: int,
    user: UserUpdate,
    user_service: UserService = Depends(get_user_service),
    token_payload: dict = Depends(AuthorizationService.verify_access_token),
):
    return await user_service.update(token_payload, user_id, user)


@user_router.delete("/delete/{user_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_user(
    user_id: int,
    user_service: UserService = Depends(get_user_service),
    token_payload: dict = Depends(AuthorizationService.verify_access_token),
):
    return await user_service.delete(token_payload, user_id)


@user_router.post("/confirm/new-password/{url_token}", response_model=UserResponse)
async def verify_new_password(
    url_token: str,
    new_password_confirm: NewPasswordConfirm,
    user_service: UserService = Depends(get_user_service),
):
    return await user_service.confirm_new_password(url_token, new_password_confirm)


@user_router.get("/confirm/new-account/{url_token}", response_model=UserResponse)
async def verify_new_account(
    url_token: str, user_service: UserService = Depends(get_user_service)
):
    return await user_service.confirm_new_account(url_token)


@user_router.get(
    "/confirm/resend-verification-new-account", status_code=status.HTTP_204_NO_CONTENT
)
async def resend_verification(
    email: EmailStr,
    email_verification_service: EmailVerificationService = Depends(
        get_email_verification_service
    ),
):
    return await email_verification_service.resend_verification(email)
