from uuid import UUID

from backend.models import UserWeightHistory
from backend.user_details.schemas import UserWeightHistoryCreate, UserWeightHistoryResponse


def weight_history_to_response(data: UserWeightHistory) -> UserWeightHistoryResponse:
    return UserWeightHistoryResponse(
        weight_kg=data.weight_kg,
        day=data.day,
    )


def weight_history_create_to_entry(user_id: UUID, data: UserWeightHistoryCreate) -> UserWeightHistory:
    return UserWeightHistory(
        user_id=user_id,
        weight_kg=data.weight_kg,
        day=data.day,
    )
