from uuid import UUID

from backend.models import User
from backend.users.schemas import TokenPayload, UserCreate


def user_create_to_entity(user_data: UserCreate, role_id: UUID) -> User:
    return User(**user_data.model_dump(), role_id=role_id)


def decoded_token_to_payload(token_data: dict) -> TokenPayload:
    payload_dict = token_data.copy()
    payload_dict["email"] = payload_dict.pop("sub", None)
    return TokenPayload(**payload_dict)
