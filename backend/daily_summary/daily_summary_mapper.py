from backend.daily_summary.schemas import DailyMealTypeSummary
from backend.models import DailyMealsSummary


class DailySummaryMapper:
    @staticmethod
    def map_to_daily_meal_type(daily_summary: DailyMealsSummary) -> DailyMealTypeSummary:
        first_meal = daily_summary.daily_meals[0] if daily_summary.daily_meals else None
        print(first_meal.meal_type)
        return DailyMealTypeSummary(
            daily_summary_id=daily_summary.id,
            meal_daily_summary_id=first_meal.id,
            user_id=daily_summary.user_id,
            day=daily_summary.day,
            target_calories=daily_summary.target_calories,
            target_protein=daily_summary.target_protein,
            target_carbs=daily_summary.target_carbs,
            target_fat=daily_summary.target_fat,
            status=first_meal.status if first_meal else None,
            meal_type=first_meal.meal_type if first_meal else None,
        )
