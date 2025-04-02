from pydantic_settings import BaseSettings, SettingsConfigDict
from datetime import timezone


class Settings(BaseSettings):
    DATABASE_URL: str
    SECRET_KEY: str
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 30
    API_URL: str
    REFRESH_TOKEN_EXPIRE_HOURS: int = 3
    PEPPER_KEY: str
    REDIS_HOST: str
    REDIS_PORT: int
    TIMEZONE: timezone = timezone.utc

    model_config = SettingsConfigDict(env_file=".env", extra="ignore")


config = Settings()
