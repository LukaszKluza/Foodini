from hashlib import sha256
from passlib.context import CryptContext

from backend.settings import config

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")


class PasswordService:
    @staticmethod
    def _pre_hash_secret(password: str) -> str:
        password_with_pepper = password + config.PEPPER_KEY
        return sha256(password_with_pepper.encode('utf-8')).hexdigest()

    @staticmethod
    async def hash_password(password: str) -> str:
        pre_hash_secret = PasswordService._pre_hash_secret(password)
        return pwd_context.hash(pre_hash_secret)

    @staticmethod
    async def verify_password(plain_password: str, hashed_password: str) -> bool:
        pre_hash_secret = PasswordService._pre_hash_secret(plain_password)
        return pwd_context.verify(pre_hash_secret, hashed_password)