from fastapi import APIRouter, Depends, status
from fastapi.params import Query

from backend.core.user_authorisation_service import AuthorizationService
from backend.user_details.schemas import (
    UserDetailsResponse,
    UserDetailsCreate,
    UserDetailsUpdate,
)
from backend.user_details.service.user_details_service import UserDetailsService

user_details_router = APIRouter(prefix="/v1/user_details")


@user_details_router.get("/", response_model=UserDetailsResponse)
async def get_user_details(
    user_id: int = Query(...),
    user_details_service: UserDetailsService = Depends(),
    token_payload: dict = Depends(AuthorizationService.verify_access_token),
):
    return await user_details_service.get_user_details_by_user_id(
        token_payload, user_id
    )


@user_details_router.post(
    "/", status_code=status.HTTP_201_CREATED, response_model=UserDetailsResponse
)
async def add_user_details(
    user_details: UserDetailsCreate,
    user_id: int = Query(...),
    user_details_service: UserDetailsService = Depends(),
    token_payload: dict = Depends(AuthorizationService.verify_access_token),
):
    return await user_details_service.add_user_details(
        token_payload, user_details, user_id
    )


@user_details_router.patch("/", response_model=UserDetailsResponse)
async def update_user_details(
    user_details: UserDetailsUpdate,
    user_id: int = Query(...),
    user_details_service: UserDetailsService = Depends(),
    token_payload: dict = Depends(AuthorizationService.verify_access_token),
):
    return await user_details_service.update_user_details(
        token_payload, user_details, user_id
    )
