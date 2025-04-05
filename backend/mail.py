from fastapi_mail import FastMail, ConnectionConfig, MessageSchema, MessageType
from fastapi_mail.errors import ConnectionErrors
from fastapi import HTTPException, status
from pydantic import EmailStr
from pydantic_settings import BaseSettings, SettingsConfigDict
from typing import List


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


mail_settings = MailSettings()
mail_config = ConnectionConfig(**mail_settings.model_dump())

mail = FastMail(config=mail_config)


class MailService:
    @staticmethod
    async def create_message(recipients: List[EmailStr], subject: str, body: str):
        message = MessageSchema(
            recipients=recipients, subject=subject, body=body, subtype=MessageType.plain
        )

        return message

    @staticmethod
    async def send_message(message: MessageSchema):
        try:
            return await mail.send_message(message)
        except ConnectionErrors:
            raise HTTPException(
                status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
                detail="Email service temporarily unavailable",
            )
