from datetime import datetime

from sqlalchemy import Column, DateTime, func
from sqlmodel import Field, SQLModel

from backend.diet_prediction.enums.unit import Unit
from backend.users.enums.language import Language


class UnitTranslation(SQLModel, table=True):
    __tablename__ = "unit_translations"

    id: int = Field(default=None, primary_key=True)
    unit: Unit = Field(nullable=False, index=True)
    language: Language = Field(nullable=False, index=True)
    translation: str = Field(nullable=False)
    created_at: datetime = Field(sa_column=Column(DateTime(timezone=True), server_default=func.now()))
    updated_at: datetime = Field(
        sa_column=Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())
    )
