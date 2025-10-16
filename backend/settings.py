import os
from datetime import timezone
from typing import List

from pydantic_settings import BaseSettings, SettingsConfigDict

env = os.getenv("ENV", ".env")


class Settings(BaseSettings):
    DATABASE_URL: str
    SECRET_KEY: str
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 1
    API_URL: str
    FRONTEND_URL: str
    REFRESH_TOKEN_EXPIRE_HOURS: int = 3
    VERIFICATION_TOKEN_EXPIRE_MINUTES: int = 10
    RESET_PASSWORD_OFFSET_SECONDS: int = 24 * 3600
    PEPPER_KEY: str
    NEW_ACCOUNT_SALT: str
    NEW_PASSWORD_SALT: str
    REDIS_HOST: str
    REDIS_PORT: int
    TIMEZONE: timezone = timezone.utc
    MACROS_CHANGE_TOLERANCE: int = 30
    FAT_CONVERSION_FACTOR: int = 9
    CARBS_CONVERSION_FACTOR: int = 4
    PROTEIN_CONVERSION_FACTOR: int = 4

    model_config = SettingsConfigDict(env_file=f"{env}", extra="ignore")

    @property
    def SALTS(self) -> List[str]:
        return [self.NEW_ACCOUNT_SALT, self.NEW_PASSWORD_SALT]


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


config = Settings()
