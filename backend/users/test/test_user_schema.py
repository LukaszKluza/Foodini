import pytest
from pydantic import ValidationError
from backend.users.schemas import UserCreate


@pytest.fixture
def valid_user_data():
    return {
        "name": "Jan",
        "last_name": "Kowalski",
        "age": 25,
        "country": "Poland",
        "email": "jan@example.com",
        "password": "ValidPass123",
    }


def prepare_invalid_data(base_data, **overrides):
    return {**base_data, **overrides}


@pytest.mark.parametrize(
    "invalid_password",
    [
        "short",
        "no_upper_case1",
        "NOLOWERCASE1",
        "NoNumbers",
        "a" * 65,
    ],
)
def test_password_model_validation(valid_user_data, invalid_password):
    # Given
    invalid_data = prepare_invalid_data(valid_user_data, password=invalid_password)

    # When/Then
    with pytest.raises(ValidationError) as exc_info:
        UserCreate(**invalid_data)

    # Optional
    errors = exc_info.value.errors()
    assert len(errors) == 1


@pytest.mark.parametrize(
    "invalid_country",
    [
        "X",
        "a" * 51,
        "123",
        "Invalid@Country",
        " ",
    ],
)
def test_country_validation(valid_user_data, invalid_country):
    # Given
    invalid_data = prepare_invalid_data(valid_user_data, country=invalid_country)

    # When/Then
    with pytest.raises(ValidationError) as exc_info:
        UserCreate(**invalid_data)

    # Optional
    errors = exc_info.value.errors()
    assert len(errors) == 1


@pytest.mark.parametrize(
    "invalid_name",
    [
        "A",
        "a" * 51,
        "Name1",
        "Invalid Name",
        "Name@",
    ],
)
def test_name_validation(valid_user_data, invalid_name):
    # Given
    invalid_data = prepare_invalid_data(valid_user_data, name=invalid_name)

    # When/Then
    with pytest.raises(ValidationError) as exc_info:
        UserCreate(**invalid_data)

    # Optional
    errors = exc_info.value.errors()
    assert len(errors) >= 1


@pytest.mark.parametrize("invalid_last_name", ["A", "a" * 51, "Last1", "Last@Name", ""])
def test_last_name_validation(valid_user_data, invalid_last_name):
    # Given
    invalid_data = prepare_invalid_data(valid_user_data, last_name=invalid_last_name)

    # When/Then
    with pytest.raises(ValidationError) as exc_info:
        UserCreate(**invalid_data)

    # Optional
    errors = exc_info.value.errors()
    assert len(errors) >= 1


@pytest.mark.parametrize(
    "invalid_age",
    [
        12,
        121,
        0,
        -5,
    ],
)
def test_age_validation(valid_user_data, invalid_age):
    # Given
    invalid_data = prepare_invalid_data(valid_user_data, age=invalid_age)

    # When/Then
    with pytest.raises(ValidationError) as exc_info:
        UserCreate(**invalid_data)

    # Optional
    errors = exc_info.value.errors()
    assert len(errors) == 1


@pytest.mark.parametrize(
    "invalid_email",
    ["not-an-email", "user@", "@example.com", "user@.com", "user@example..com"],
)
def test_email_validation(valid_user_data, invalid_email):
    # Given
    invalid_data = prepare_invalid_data(valid_user_data, email=invalid_email)

    # When/Then
    with pytest.raises(ValidationError) as exc_info:
        UserCreate(**invalid_data)

    # Optional
    errors = exc_info.value.errors()
    assert len(errors) == 1
