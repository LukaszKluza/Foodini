import pytest

from backend.users.service.password_service import PasswordService


@pytest.mark.asyncio
async def test_hash_password_returns_different_value():
    # Given
    password = "test_password123!"

    # When
    hashed = await PasswordService.hash_password(password)

    # Then
    assert hashed != password
    assert isinstance(hashed, str)


@pytest.mark.asyncio
async def test_hash_password_produces_different_hashes_for_same_input():
    # Given
    password = "same_password_456@"

    # When
    hash1 = await PasswordService.hash_password(password)
    hash2 = await PasswordService.hash_password(password)

    # Then
    assert hash1 != hash2


@pytest.mark.asyncio
async def test_verify_password_correct_password():
    # Given
    password = "correct_password_789$"
    hashed = await PasswordService.hash_password(password)

    # When/Then
    assert await PasswordService.verify_password(password, hashed)


@pytest.mark.asyncio
async def test_verify_password_incorrect_password():
    # Given
    password = "original_password_012!"
    wrong_password = "wrong_password_345@"
    hashed = await PasswordService.hash_password(password)

    # When/Then
    assert not await PasswordService.verify_password(wrong_password, hashed)


@pytest.mark.asyncio
async def test_verify_password_empty_password():
    # Given
    password = ""
    hashed = await PasswordService.hash_password(password)

    # When/Then
    assert await PasswordService.verify_password(password, hashed)


@pytest.mark.asyncio
async def test_hash_password_special_chars():
    # Given
    password = "p@$$w0rd_w!th_sp€c!@l_ch@rs"

    # When
    hashed = await PasswordService.hash_password(password)

    # Then
    assert await PasswordService.verify_password(password, hashed)


@pytest.mark.asyncio
async def test_hash_password_long_password():
    # Given
    password = "x" * 1000

    # When
    hashed = await PasswordService.hash_password(password)

    # Then
    assert await PasswordService.verify_password(password, hashed)
