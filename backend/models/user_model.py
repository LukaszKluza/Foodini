import uuid
from datetime import datetime
from typing import TYPE_CHECKING, List, Optional

from pydantic import EmailStr
from sqlalchemy import UUID, Column, DateTime, Index, func
from sqlmodel import Field, Relationship, SQLModel

from backend.settings import config
from backend.users.enums.language import Language

from ..core.db_listeners import register_timestamp_listeners

if TYPE_CHECKING:
    from .user_daily_summary_model import DailyMacrosSummary, DailyMealsSummary
    from .user_details_model import UserDetails
    from .user_diet_prediction_model import UserDietPredictions


class User(SQLModel, table=True):
    __tablename__ = "users"
    __table_args__ = (Index("ix_user_mail", func.lower(Column("email")), unique=True),)

    id: uuid.UUID = Field(
        default_factory=uuid.uuid4, sa_column=Column(UUID(as_uuid=True), primary_key=True, unique=True, nullable=False)
    )
    name: str
    last_name: str
    country: str
    email: EmailStr = Field(unique=True, nullable=False)
    language: Language = Field(default=Language.EN)
    is_verified: bool = Field(default=False)
    password: str
    last_password_update: datetime = Field(
        default_factory=lambda: datetime.now(config.TIMEZONE),
        sa_column=Column(DateTime(timezone=True)),
    )

    details: Optional["UserDetails"] = Relationship(
        back_populates="user", sa_relationship_kwargs={"passive_deletes": True}
    )
    diet_predictions: Optional["UserDietPredictions"] = Relationship(
        back_populates="user", sa_relationship_kwargs={"passive_deletes": True}
    )
    daily_meals_summaries: List["DailyMealsSummary"] = Relationship(
        back_populates="user", sa_relationship_kwargs={"passive_deletes": True}
    )
    daily_macros_summaries: List["DailyMacrosSummary"] = Relationship(
        back_populates="user", sa_relationship_kwargs={"passive_deletes": True}
    )

    created_at: datetime = Field(sa_column=Column(DateTime(timezone=True), server_default=func.now()))
    updated_at: datetime = Field(
        sa_column=Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())
    )


register_timestamp_listeners([User])
