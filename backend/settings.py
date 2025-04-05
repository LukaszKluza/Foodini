from pydantic_settings import BaseSettings, SettingsConfigDict
from datetime import timezone
from typing import List


class Settings(BaseSettings):
    DATABASE_URL: str
    SECRET_KEY: str
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 30
    API_URL: str
    REFRESH_TOKEN_EXPIRE_HOURS: int = 3
    VERIFICATION_TOKEN_EXPIRE_MINUTES: int = 10
    RESET_PASSWORD_OFFSET_SECONDS: int = 24 * 3600
    PEPPER_KEY: str
    NEW_ACCOUNT_SALT: str
    NEW_PASSWORD_SALT: str
    REDIS_HOST: str
    REDIS_PORT: int
    TIMEZONE: timezone = timezone.utc
    MAIL_USERNAME: str
    MAIL_PASSWORD: str
    MAIL_FROM: str
    MAIL_PORT: int
    MAIL_SERVER: str
    MAIL_FROM_NAME: str

    model_config = SettingsConfigDict(env_file=".env", extra="ignore")

    @property
    def SALTS(self) -> List[str]:
        return [self.NEW_ACCOUNT_SALT, self.NEW_PASSWORD_SALT]


config = Settings()
