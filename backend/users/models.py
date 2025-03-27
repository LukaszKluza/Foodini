from sqlmodel import SQLModel, Field


class User(SQLModel, table=True):
    __tablename__ = "users"

    id: int = Field(default=None, primary_key=True)
    name: str = Field(nullable=False)
    last_name: str = Field(nullable=False)
    age: int = Field(nullable=False)
    country: str = Field(nullable=False)
    email: str = Field(unique=True, nullable=False)
    password: str = Field(nullable=False)


class BodyParameters(SQLModel, table=True):
    __tablename__ = "body_parameters"

    id: int = Field(default=None, primary_key=True)
    user_id: int = Field(foreign_key="users.id", nullable=False)
    height_cm: float = Field(nullable=False)
    weight_kg: float = Field(nullable=False)
    gender: str = Field(max_length=50, nullable=False)
    activity_level: str = Field(max_length=50, nullable=False)
    number_of_meals: int = Field(nullable=False)
    cooking_skills: str = Field(max_length=50, nullable=False)
    goal: str = Field(max_length=50, nullable=False)
