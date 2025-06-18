from fastapi import APIRouter, Depends, status

from backend.models import UserDetails
from backend.user_details.schemas import (
    UserDetailsCreate,
    UserDetailsUpdate,
)
from backend.user_details.service.user_details_service import UserDetailsService
from backend.users.user_gateway import UserGateway, get_user_gateway
from backend.user_details.dependencies import get_user_details_service

#
user_details_router = APIRouter(prefix="/v1/user_details")


@user_details_router.get("/", response_model=UserDetails)
async def get_user_details(
    user_details_service: UserDetailsService = Depends(get_user_details_service),
    user_gateway: UserGateway = Depends(get_user_gateway),
):
    user, _ = await user_gateway.get_current_user()
    return await user_details_service.get_user_details_by_user(user)


@user_details_router.post(
    "/", status_code=status.HTTP_201_CREATED, response_model=UserDetails
)
async def add_user_details(
    user_details: UserDetailsCreate,
    user_details_service: UserDetailsService = Depends(get_user_details_service),
    user_gateway: UserGateway = Depends(get_user_gateway),
):
    user, _ = await user_gateway.get_current_user()
    return await user_details_service.add_user_details(user_details, user)


@user_details_router.patch("/", response_model=UserDetails)
async def update_user_details(
    user_details: UserDetailsUpdate,
    user_details_service: UserDetailsService = Depends(get_user_details_service),
    user_gateway: UserGateway = Depends(get_user_gateway),
):
    user, _ = await user_gateway.get_current_user()
    return await user_details_service.update_user_details(user_details, user)
