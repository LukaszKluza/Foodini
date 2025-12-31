from backend.daily_summary.schemas import (
    DailyMealTypesSummaryWithItems,
    DailyMealTypeSummary,
    MealTypeDailySummaryBase,
    MealTypeDailySummaryWithItems,
)
from backend.models import DailySummary


class DailySummaryMapper:
    @staticmethod
    def map_to_daily_meal_type(daily_summary: DailySummary) -> DailyMealTypeSummary | None:
        if not daily_summary:
            return None
        meal_type_daily_summary = None
        first_meal = daily_summary.daily_meals[0] if daily_summary.daily_meals else None
        if first_meal:
            meal_type_daily_summary = MealTypeDailySummaryBase(
                meal_daily_summary_id=first_meal.id,
                status=first_meal.status,
                meal_type=first_meal.meal_type,
            )
        return DailyMealTypeSummary(
            daily_summary_id=daily_summary.id,
            user_id=daily_summary.user_id,
            day=daily_summary.day,
            target_calories=daily_summary.target_calories,
            target_protein=daily_summary.target_protein,
            target_carbs=daily_summary.target_carbs,
            target_fat=daily_summary.target_fat,
            meal_type_daily_summary=meal_type_daily_summary,
        )

    @staticmethod
    def map_daily_meal_types_summary_with_items(daily_summary: DailySummary) -> DailyMealTypesSummaryWithItems | None:
        if not daily_summary:
            return None
        meal_type_daily_summaries = {}

        for meal in daily_summary.daily_meals:
            meal_type_daily_summaries[meal.meal_type] = MealTypeDailySummaryWithItems(
                meal_daily_summary_id=meal.id,
                status=meal.status,
                meal_type=meal.meal_type,
                composed_meal_items=meal.meal_items,
            )
        return DailyMealTypesSummaryWithItems(
            daily_summary_id=daily_summary.id,
            user_id=daily_summary.user_id,
            day=daily_summary.day,
            target_calories=daily_summary.target_calories,
            target_protein=daily_summary.target_protein,
            target_carbs=daily_summary.target_carbs,
            target_fat=daily_summary.target_fat,
            map_meal_type_daily_summaries=meal_type_daily_summaries,
        )
