from datetime import datetime, timedelta
from typing import Type

from backend.core.not_found_in_database_exception import NotFoundInDatabaseException
from backend.daily_summary.daily_summary_gateway import DailySummaryGateway
from backend.models import User
from backend.user_details.user_details_gateway import UserDetailsGateway
from backend.user_statistics.schemas import DailyCaloriesStat, UserStatisticsSchema


class UserStatisticsService:
    def __init__(
        self,
        daily_summary_gateway: DailySummaryGateway,
        user_details_gateway: UserDetailsGateway,
    ):
        self.daily_summary_gateway = daily_summary_gateway
        self.user_details_gateway = user_details_gateway

    async def get_user_weekly_statistics(self, user: Type[User]) -> UserStatisticsSchema:
        today = datetime.today()
        offset = today.weekday()
        current_date = today - timedelta(days=offset)

        user_diet_predictions = await self.user_details_gateway.get_user_diet_predictions(user)

        target_calories = user_diet_predictions.target_calories
        weekly_calories_consumption = []

        for _ in range(7):
            try:
                current_day_macros_summary = await self.daily_summary_gateway.get_daily_macros_summary(
                    user.id, current_date.date()
                )
                current_calories_consumption = current_day_macros_summary.calories
            except NotFoundInDatabaseException:
                # TODO: we should probably refactor getting methods to not throw exception in every case
                current_calories_consumption = 0
                pass

            weekly_calories_consumption.append(
                DailyCaloriesStat(day=current_date.date(), calories=current_calories_consumption)
            )
            current_date = current_date + timedelta(days=1)

        return UserStatisticsSchema(
            target_calories=target_calories, weekly_calories_consumption=weekly_calories_consumption
        )
