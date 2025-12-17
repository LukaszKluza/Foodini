from datetime import date
from typing import List, Type

from backend.models import User
from backend.user_details.mappers import weight_history_create_to_entry, weight_history_to_response
from backend.user_details.schemas import (
    UserWeightHistoryCreate,
    UserWeightHistoryResponse,
)
from backend.user_details.user_weight_repository import UserWeightRepository


class UserWeightService:
    def __init__(self, user_weight_repository: UserWeightRepository):
        self.user_weight_repository = user_weight_repository

    async def add_user_weight(self, data: UserWeightHistoryCreate, user: Type[User]) -> UserWeightHistoryResponse:
        entry = weight_history_create_to_entry(user.id, data)
        return weight_history_to_response(await self.user_weight_repository.add_user_weight(entry))

    async def get_weight_for_day(self, user: Type[User], day: date) -> UserWeightHistoryResponse | None:
        entry = await self.user_weight_repository.get_user_weight_history_by_user_id_and_day(user.id, day)
        return weight_history_to_response(entry) if entry else None

    async def get_weight_range(
        self, user: Type[User], start_date: date, end_date: date
    ) -> List[UserWeightHistoryResponse]:
        entries = await self.user_weight_repository.get_user_weight_history_by_user_id_and_date_range(
            user.id, start_date, end_date
        )
        return [weight_history_to_response(entry) for entry in entries]
