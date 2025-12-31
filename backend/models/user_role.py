import uuid
from typing import TYPE_CHECKING, List

from sqlalchemy import Column, String
from sqlmodel import Field, Relationship, SQLModel

if TYPE_CHECKING:
    from .user_model import User


class UserRole(SQLModel, table=True):
    __tablename__ = "user_roles"

    id: uuid.UUID = Field(
        default_factory=uuid.uuid4,
        primary_key=True,
        nullable=False,
    )

    name: str = Field(sa_column=Column(String, unique=True, nullable=False, index=True))

    users: List["User"] = Relationship(
        back_populates="role", sa_relationship_kwargs={"primaryjoin": "UserRole.id==User.role_id"}
    )
