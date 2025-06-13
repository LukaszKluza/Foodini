from passlib.context import CryptContext

from backend.settings import config

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")


class PasswordService:
    @classmethod
    async def hash_password(cls, password: str) -> str:
        password_with_pepper = password + config.PEPPER_KEY
        return pwd_context.hash(password_with_pepper)

    @classmethod
    async def verify_password(cls, plain_password: str, hashed_password: str) -> bool:
        return pwd_context.verify(plain_password + config.PEPPER_KEY, hashed_password)
