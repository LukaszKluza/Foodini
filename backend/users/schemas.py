from pydantic import BaseModel, EmailStr


class UserCreate(BaseModel):
    name: str
    last_name: str
    age: int
    country: str
    email: EmailStr
    password: str


class UserUpdate(BaseModel):
    user_id: int
    name: str = None
    last_name: str = None
    age: int = None
    country: str = None


class UserLogin(BaseModel):
    email: EmailStr
    password: str


class UserLogout(BaseModel):
    id: int
    email: EmailStr


class UserResponse(BaseModel):
    id: int
    email: EmailStr
    token: str | None = None
