from passlib.context import CryptContext

from backend.Settings import config

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")


class PasswordService:
    @staticmethod
    async def hash_password(password: str) -> str:
        password_with_pepper = password + config.PEPPER_KEY
        return pwd_context.hash(password_with_pepper)

    @staticmethod
    async def verify_password(plain_password: str, hashed_password: str) -> bool:
        return pwd_context.verify(plain_password + config.PEPPER_KEY, hashed_password)
