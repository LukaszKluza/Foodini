import uuid
from datetime import date, datetime
from typing import Optional

from sqlalchemy import UUID, CheckConstraint, ForeignKey, Index, UniqueConstraint
from sqlmodel import Column, DateTime, Field, Relationship, SQLModel, func

from ..core.db_listeners import register_timestamp_listeners
from .types import FloatAsNumeric


class UserWeightHistory(SQLModel, table=True):
    __tablename__ = "user_weight_history"
    __table_args__ = (
        UniqueConstraint("day", "user_id", name="uq_user_weight_day"),
        Index("ix_user_weight_user_day", "user_id", "day"),
        CheckConstraint("weight_kg >= 20 AND weight_kg <= 160", name="ck_weight_history_range"),
    )

    id: uuid.UUID = Field(
        default_factory=uuid.uuid4, sa_column=Column(UUID(as_uuid=True), primary_key=True, unique=True, nullable=False)
    )
    user_id: uuid.UUID = Field(sa_column=Column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE")))
    day: date = Field(nullable=False)

    weight_kg: float = Field(sa_column=Column(FloatAsNumeric, nullable=False), ge=20, le=160)

    created_at: datetime = Field(sa_column=Column(DateTime(timezone=True), server_default=func.now()))
    updated_at: datetime = Field(
        sa_column=Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())
    )

    user: Optional["User"] = Relationship(
        back_populates="weight_history", sa_relationship_kwargs={"passive_deletes": True}
    )


register_timestamp_listeners([UserWeightHistory])
