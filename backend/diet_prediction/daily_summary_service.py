from datetime import date
from typing import Optional, Type

from backend.diet_prediction.daily_summary_repository import DailySummaryRepository
from backend.diet_prediction.schemas import DailySummaryResponse, MealResponse, UserDailySummaryCreate
from backend.models import User
from backend.models.user_daily_summary_model import UserDailyMealItem, UserDailySummary


def make_daily_summary_response(summary: UserDailySummary) -> DailySummaryResponse:
    return DailySummaryResponse(
        id=summary.id,
        day=summary.day,
        calories_consumed=summary.calories_consumed,
        protein_consumed=summary.protein_consumed,
        fat_consumed=summary.fat_consumed,
        carbs_consumed=summary.carbs_consumed,
        next_meal=summary.next_meal,
        meal_items=[
            MealResponse(
                id=item.meal_id,
                name=item.meal.name,
                calories=item.meal.calories,
                protein=int(item.meal.protein),
                fat=int(item.meal.fat),
                carbs=int(item.meal.carbs),
                status=item.status.value,
            )
            for item in summary.meal_items
        ],
    )


class DailySummaryService:
    def __init__(self, meals_repo: DailySummaryRepository):
        self.daily_summary_repo = meals_repo

    async def add_summary(
        self, daily_summary_data: UserDailySummaryCreate, user: Type[User]
    ) -> Optional[DailySummaryResponse]:
        summary = await self.daily_summary_repo.add_daily_summary(daily_summary_data, user.id)

        return make_daily_summary_response(summary)

    async def get_summary(self, user_id: int, day: date) -> Optional[DailySummaryResponse]:
        summary = await self.daily_summary_repo.get_daily_summary(user_id, day)
        if not summary:
            return None

        return make_daily_summary_response(summary)

    async def get_next_meal(self, user_id: int, day: date) -> Optional[UserDailyMealItem]:
        return await self.daily_summary_repo.get_next_meal(user_id, day)

    async def update_meal_status(self, daily_summary_id: int, eaten_meal_id: int) -> Optional[UserDailySummary]:
        return await self.daily_summary_repo.update_daily_summary(daily_summary_id, eaten_meal_id)
