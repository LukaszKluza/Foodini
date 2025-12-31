import uuid
from datetime import datetime
from typing import TYPE_CHECKING, List

from sqlalchemy import Column, DateTime, String, func
from sqlmodel import Field, Relationship, SQLModel

from ..core.db_listeners import register_timestamp_listeners

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

    created_at: datetime = Field(sa_column=Column(DateTime(timezone=True), server_default=func.now()))
    updated_at: datetime = Field(
        sa_column=Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())
    )

    users: List["User"] = Relationship(
        back_populates="role", sa_relationship_kwargs={"primaryjoin": "UserRole.id==User.role_id"}
    )


register_timestamp_listeners([UserRole])