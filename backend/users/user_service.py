from backend.users.schemas import UserCreate, UserLogin, UserUpdate


class UserCrud:
    def __init__(self):
        pass

    def register(self, user: UserCreate):
        pass

    def login(self, user: UserLogin):
        pass

    def logout(self, user_id: int):
        pass

    def update(self, user: UserUpdate):
        pass

    def delete(self, user_id: int):
        pass
