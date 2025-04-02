from fastapi_mail import FastMail, ConnectionConfig, MessageSchema, MessageType
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


def create_message(recipients: List[str], subject: str, body: str):
    message = MessageSchema(
        recipients=recipients, subject=subject, body=body, subtype=MessageType.plain
    )

    return message
