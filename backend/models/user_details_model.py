import uuid
from datetime import date, datetime
from typing import TYPE_CHECKING, List, Optional

from sqlalchemy import ARRAY, UUID, Column, DateTime, Enum, ForeignKey, func
from sqlmodel import Field, Relationship, SQLModel

from backend.user_details.enums import (
    ActivityLevel,
    DietaryRestriction,
    DietIntensity,
    DietType,
    Gender,
    SleepQuality,
    StressLevel,
)
from backend.user_details.mixins import DietGoalValidationMixin

if TYPE_CHECKING:
    from .user_model import User


class UserDetails(DietGoalValidationMixin, SQLModel, table=True):
    __tablename__ = "user_details"

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
    user: Optional["User"] = Relationship(back_populates="details", sa_relationship_kwargs={"cascade": "all, delete"})
    gender: Gender = Field(nullable=False)
    height_cm: float = Field(ge=60, le=230)
    weight_kg: float = Field(ge=20, le=160)
    date_of_birth: date
    diet_type: DietType = Field(nullable=False)
    dietary_restrictions: List[DietaryRestriction] = Field(
        sa_column=Column(ARRAY(Enum(DietaryRestriction))), default=[]
    )
    diet_goal_kg: float
    meals_per_day: int = Field(ge=1, le=6)
    diet_intensity: DietIntensity = Field(nullable=False)
    activity_level: ActivityLevel = Field(nullable=False)
    stress_level: StressLevel = Field(nullable=False)
    sleep_quality: SleepQuality = Field(nullable=False)
    muscle_percentage: Optional[float] = Field(default=None, ge=0, le=100)
    water_percentage: Optional[float] = Field(default=None, ge=0, le=100)
    fat_percentage: Optional[float] = Field(default=None, ge=0, le=100)

    created_at: datetime = Field(sa_column=Column(DateTime(timezone=True), server_default=func.now()))
    updated_at: datetime = Field(
        sa_column=Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())
    )

    @property
    def age(self) -> int:
        today = date.today()
        dob = self.date_of_birth
        age = today.year - dob.year - ((today.month, today.day) < (dob.month, dob.day))
        return age
