from passlib.context import CryptContext

from backend.Settings import PAPER_KEY

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")
PAPER_KEY = PAPER_KEY


class PasswordService:
    @staticmethod
    async def hash_password(password: str) -> str:
        password_with_pepper = password + PAPER_KEY
        return pwd_context.hash(password_with_pepper)

    @staticmethod
    async def verify_password(plain_password: str, hashed_password: str) -> bool:
        return pwd_context.verify(plain_password + PAPER_KEY, hashed_password)
