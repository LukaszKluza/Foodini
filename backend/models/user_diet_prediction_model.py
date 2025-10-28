import uuid
from datetime import datetime
from typing import TYPE_CHECKING, Optional

from sqlalchemy import UUID, CheckConstraint, Column, DateTime, ForeignKey, Index, Numeric, event, func
from sqlmodel import Field, Relationship, SQLModel

if TYPE_CHECKING:
    from .user_model import User


class UserDietPredictions(SQLModel, table=True):
    __tablename__ = "user_diet_predictions"
    __table_args__ = (
        Index("ix_user_diet_prediction", "user_id"),
        CheckConstraint("target_calories >= 0", name="ck_target_calories_nonnegative"),
        CheckConstraint("protein >= 0", name="ck_protein_nonnegative"),
        CheckConstraint("carbs >= 0", name="ck_carbs_nonnegative"),
        CheckConstraint("fat >= 0", name="ck_fat_nonnegative"),
        CheckConstraint("bmr >= 0", name="ck_bmr_nonnegative"),
        CheckConstraint("tdee >= 0", name="ck_tdee_nonnegative"),
    )

    id: uuid.UUID = Field(
        default_factory=uuid.uuid4, sa_column=Column(UUID(as_uuid=True), primary_key=True, unique=True, nullable=False)
    )
    user_id: uuid.UUID = Field(
        sa_column=Column(
            UUID(as_uuid=True),
            ForeignKey("users.id", ondelete="CASCADE"),
            nullable=False,
            unique=True,
        )
    )
    user: Optional["User"] = Relationship(
        back_populates="diet_predictions", sa_relationship_kwargs={"cascade": "all, delete"}
    )
    protein: float = Field(sa_column=Column(Numeric(10, 2), nullable=False), ge=0)
    fat: float = Field(sa_column=Column(Numeric(10, 2), nullable=False), ge=0)
    carbs: float = Field(sa_column=Column(Numeric(10, 2), nullable=False), ge=0)
    bmr: int = Field(ge=0)
    tdee: int = Field(ge=0)
    target_calories: int = Field(ge=0)
    diet_duration_days: Optional[int] = None

    created_at: datetime = Field(sa_column=Column(DateTime(timezone=True), server_default=func.now()))
    updated_at: datetime = Field(
        sa_column=Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())
    )


@event.listens_for(UserDietPredictions, "before_update")
def update_timestamps(mapper, connection, target):
    target.updated_at = datetime.now()
