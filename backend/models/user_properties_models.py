from typing import List, Optional, TYPE_CHECKING
from sqlmodel import Relationship, SQLModel, Field

if TYPE_CHECKING:
    from .user_details_model import UserDetails


class Gender(SQLModel, table=True):
    __tablename__ = "gender"

    id: int = Field(default=None, primary_key=True)
    name: str = Field(unique=True)


class AllergyLink(SQLModel, table=True):
    user_details_id: Optional[int] = Field(
        default=None, foreign_key="user_details.id", primary_key=True
    )
    allergy_id: Optional[int] = Field(
        default=None, foreign_key="allergies.id", primary_key=True
    )


class Allergies(SQLModel, table=True):
    __tablename__ = "allergies"

    id: int = Field(default=None, primary_key=True)
    name: str = Field(unique=True)

    user_details: List["UserDetails"] = Relationship(
        back_populates="allergies", link_model=AllergyLink
    )


class DietType(SQLModel, table=True):
    __tablename__ = "diet_type"

    id: int = Field(default=None, primary_key=True)
    name: str = Field(unique=True)


class DietIntensivity(SQLModel, table=True):
    __tablename__ = "diet_intensivity"

    id: int = Field(default=None, primary_key=True)
    name: str = Field(unique=True)


class ActivityLevel(SQLModel, table=True):
    __tablename__ = "activity_level"

    id: int = Field(default=None, primary_key=True)
    name: str = Field(unique=True)


class StressLevel(SQLModel, table=True):
    __tablename__ = "stress_level"

    id: int = Field(default=None, primary_key=True)
    name: str = Field(unique=True)


class SleepQuality(SQLModel, table=True):
    __tablename__ = "sleep_quality"

    id: int = Field(default=None, primary_key=True)
    name: str = Field(unique=True)
