import pytest
from backend.users.service.password_service import PasswordService


@pytest.mark.asyncio
async def test_hash_password():
    password = "test_password"
    hashed_password = await PasswordService.hash_password(password)

    assert hashed_password != password
    assert len(hashed_password) > len(password)


@pytest.mark.asyncio
async def test_verify_password():
    password = "test_password"
    hashed_password = await PasswordService.hash_password(password)

    assert await PasswordService.verify_password(password, hashed_password)
    assert not await PasswordService.verify_password("wrong_password", hashed_password)
