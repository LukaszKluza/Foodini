import redis.asyncio as aioredis
from fastapi import Depends, Security
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from fastapi_mail import ConnectionConfig, FastMail
from pydantic_settings import BaseSettings, SettingsConfigDict

from backend.core.database import get_redis
from backend.core.user_authorisation_service import AuthorizationService
from backend.users.mail import MailService
from backend.users.service.email_verification_sevice import EmailVerificationService
from backend.users.service.user_service import UserService
from backend.users.service.user_validation_service import UserValidationService
from backend.users.user_repository import UserRepository, get_user_repository

security = HTTPBearer()


class MailSettings(BaseSettings):
    MAIL_USERNAME: str
    MAIL_PASSWORD: str
    MAIL_FROM: str
    MAIL_PORT: int
    MAIL_SERVER: str
    MAIL_FROM_NAME: str
    MAIL_STARTTLS: bool = True
    MAIL_SSL_TLS: bool = False
    USE_CREDENTIALS: bool = True
    VALIDATE_CERTS: bool = True

    model_config = SettingsConfigDict(env_file=".env", extra="ignore")


def get_mail_config() -> FastMail:
    settings = MailSettings()
    mail_config = ConnectionConfig(**settings.model_dump())
    return FastMail(config=mail_config)


def get_mail_service(mail_config: FastMail = Depends(get_mail_config)) -> MailService:
    return MailService(mail_config)


def get_authorization_service(redis: aioredis = Depends(get_redis)):
    return AuthorizationService(redis)


def get_user_validators(
    user_repository: UserRepository = Depends(get_user_repository),
) -> UserValidationService:
    return UserValidationService(user_repository)


def get_email_verification_service(
    user_repository: UserRepository = Depends(get_user_repository),
    user_validators: UserValidationService = Depends(get_user_validators),
    mail_service: MailService = Depends(get_mail_service),
    authorization_service: AuthorizationService = Depends(get_authorization_service),
) -> EmailVerificationService:
    return EmailVerificationService(
        user_repository, user_validators, mail_service, authorization_service
    )


def get_user_service(
    user_repository: UserRepository = Depends(get_user_repository),
    email_verification_service: EmailVerificationService = Depends(
        get_email_verification_service
    ),
    user_validators: UserValidationService = Depends(get_user_validators),
    authorization_service: AuthorizationService = Depends(get_authorization_service),
) -> UserService:
    return UserService(
        user_repository,
        email_verification_service,
        user_validators,
        authorization_service,
    )


async def get_token_payload(
    authorization_service: AuthorizationService = Depends(get_authorization_service),
    credentials: HTTPAuthorizationCredentials = Security(security),
):
    return await authorization_service.verify_access_token(credentials)
