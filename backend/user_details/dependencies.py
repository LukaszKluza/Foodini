from fastapi.params import Depends
from backend.core.database import get_db
from sqlmodel.ext.asyncio.session import AsyncSession
from backend.user_details.user_details_repository import UserDetailsRepository
from backend.user_details.service.user_details_validation_service import UserDetailsValidationService
from backend.users.user_gateway import UserGateway, get_user_gateway
from backend.user_details.service.user_details_service import UserDetailsService
from backend.user_details.service.calories_prediction_service import CaloriesPredictionService


async def get_user_details_repository(
        db: AsyncSession = Depends(get_db),
) -> UserDetailsRepository:
    return UserDetailsRepository(db)


def get_user_details_validators(
        user_details_repository: UserDetailsRepository = Depends(get_user_details_repository),
) -> UserDetailsValidationService:
    return UserDetailsValidationService(user_details_repository)


def get_user_details_service(
        user_details_repository: UserDetailsRepository = Depends(get_user_details_repository),
        user_gateway: UserGateway = Depends(get_user_gateway),
        user_details_validators: UserDetailsValidationService = Depends(get_user_details_validators),
):
    return UserDetailsService(user_details_repository, user_gateway, user_details_validators)

def get_calories_prediction_service(
        user_details_service: UserDetailsService = Depends(get_user_details_service)
):
    return CaloriesPredictionService(user_details_service)
