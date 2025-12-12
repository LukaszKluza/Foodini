from pydantic import BaseModel, Field


class ProductDetails(BaseModel):
    name: str = Field(default="")
    calories: int = Field(default=0, ge=0)
    protein: float = Field(default=0, ge=0)
    fat: float = Field(default=0, ge=0)
    carbs: float = Field(default=0, ge=0)
    weight: int = Field(default=0, ge=0)
    eaten_weight: int = Field(default=0, ge=0)
