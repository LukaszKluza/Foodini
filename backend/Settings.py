from pydantic_settings import BaseSettings, SettingsConfigDict
from datetime import timezone


class Settings(BaseSettings):
    DATABASE_URL: str
    SECRET_KEY: str
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 30
    API_URL: str
    REFRESH_TOKEN_EXPIRE_HOURS: int = 3
    VERIFICATION_TOKEN_EXPIRE_MINUTES: int = 10
    PEPPER_KEY: str
    NEW_ACCOUNT_SLAT: str
    NEW_PASSWORD_SLAT: str
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

    def __post_init__(self):
        self.SALTS = [self.NEW_ACCOUNT_SLAT, self.NEW_PASSWORD_SLAT]


config = Settings()
