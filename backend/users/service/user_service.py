from fastapi import HTTPException, status
from fastapi.params import Depends

from backend.users.service.authorisation_service import AuthorizationService
from backend.users.service.password_service import PasswordService
from backend.users.schemas import (
    UserCreate,
    UserLogin,
    UserUpdate,
    LoginUserResponse,
)
from backend.users.user_repository import UserRepository, get_user_repository
from backend.mail import mail, create_message
from backend.settings import config


async def check_user_permission(user_id_from_token: int, user_id: int):
    if user_id_from_token != user_id:
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

        await self.send_verification_message(new_user.email)

        return new_user

    async def login(self, user: UserLogin):
        user_ = await self.user_repository.get_user_by_email(user.email)
        if not user_:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Incorrect credentials",
            )

        if not user_.is_verified:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Account not verified. Please check your email for verification link.",
            )

        if not await PasswordService.verify_password(user.password, user_.password):
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
        user_ = await self.user_repository.get_user_by_id(user_id)
        if not user_:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="User with this ID does not exist",
            )

        return HTTPException(status_code=status.HTTP_200_OK, detail="Logged out")

    async def update(
        self, user_id_from_token: int, user_id_from_request, user: UserUpdate
    ):
        await check_user_permission(user_id_from_token, user_id_from_request)
        user_ = await self.user_repository.get_user_by_id(user_id_from_request)
        if not user_ or user_.id != user_id_from_request:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="User with this ID does not exist",
            )

        return await self.user_repository.update_user(user_id_from_request, user)

    async def delete(self, user_id_from_token: int, user_id: int):
        await check_user_permission(user_id_from_token, user_id)
        user_ = await self.user_repository.get_user_by_id(user_id)
        if not user_:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="User with this ID does not exist",
            )

        return await self.user_repository.delete_user(user_id)

    async def verify(self, token: str):
        token_data = await AuthorizationService.decode_url_safe_token(token)
        user_email = token_data.get("email")
        user_ = await self.user_repository.get_user_by_email(user_email)
        if not user_:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="User with this Email does not exist",
            )

        return await self.user_repository.verify_user(user_email)

    async def send_verification_message(self, email: str):
        existing_user = await self.user_repository.get_user_by_email(email)
        if not existing_user:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="User does not exist",
            )

        if existing_user.is_verified:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="User is already verified",
            )

        try:
            token = await AuthorizationService.create_url_safe_token({"email": email})
            message_link = f"{config.API_URL}/v1/users/verify/{token}"
            message_subject = "FoodiniApp email verification"
            message_body = f"Please click this {message_link} to verify your email"

            message = create_message(
                recipients=[email], subject=message_subject, body=message_body
            )

            await mail.send_message(message)
        except Exception as e:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail="Failed to send verification email",
            ) from e


def get_user_service(
    user_repository: UserRepository = Depends(get_user_repository),
) -> UserService:
    return UserService(user_repository)
