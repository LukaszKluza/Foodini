from typing import List

from backend.diet_generation.enums.meal_type import MealType
from backend.diet_generation.schemas import DailyMacrosSummaryCreate, DailyMealsCreate, MealCreate
from backend.models import MealRecipe, UserDetails, UserDietPredictions


class DietValidationService:
    CALORIES_TOLERANCE = 0.1
    PROTEIN_TOLERANCE = 25

    def validate_and_adjust_diet(
        self,
        user_details: UserDetails,
        user_diet_predictions: UserDietPredictions,
        daily_meals: DailyMealsCreate,
        meal_recipe: MealRecipe,
        daily_macros_summary: DailyMacrosSummaryCreate,
    ):
        # Implement validation logic here
        # For example, check if the diet plan meets nutritional requirements
        return True

    @classmethod
    def _validate_macros(cls, user_diet_predictions: UserDietPredictions, meals: List[MealCreate]):
        total_calories = sum(meal.calories for meal in meals)
        total_protein = sum(meal.protein for meal in meals)
        total_carbs = sum(meal.carbs for meal in meals)
        total_fats = sum(meal.fat for meal in meals)

        if (
            abs(total_calories - user_diet_predictions.target_calories)
            > user_diet_predictions.target_calories * cls.CALORIES_TOLERANCE
        ):
            raise ValueError(f"Calories mismatch: {total_calories} vs target {user_diet_predictions.target_calories}")
        if abs(total_protein - user_diet_predictions.protein) > cls.PROTEIN_TOLERANCE:
            raise ValueError(f"Protein mismatch: {total_protein} vs target {user_diet_predictions.protein}")
        if abs(total_carbs - user_diet_predictions.carbs) > user_diet_predictions.carbs * cls.CALORIES_TOLERANCE:
            raise ValueError(f"Carbs mismatch: {total_carbs} vs target {user_diet_predictions.carbs}")
        if abs(total_fats - user_diet_predictions.fat) > user_diet_predictions.fat * cls.CALORIES_TOLERANCE:
            raise ValueError(f"Fat mismatch: {total_fats} vs target {user_diet_predictions.fat}")

        return True

    @staticmethod
    def _validate_number_and_type_of_meals(user_details: UserDetails, daily_meals: DailyMealsCreate):
        if len(daily_meals.meals) != user_details.meals_per_day:
            raise ValueError(
                f"Invalid number of meals: expected {user_details.meals_per_day}, got {len(daily_meals.meals)}"
            )
        if set(daily_meals.meals.keys()) != set(MealType.daily_meals(user_details.meals_per_day)):
            raise ValueError("Meal types mismatch")
        return True

    @staticmethod
    def _validate_meal_recipe(meal_recipe: MealRecipe):
        if len(meal_recipe.ingredients.ingredients) < 1 or len(meal_recipe.ingredients.ingredients) > 25:
            raise ValueError(f"Invalid number of ingredients: {len(meal_recipe.ingredients.ingredients)}")
        if len(meal_recipe.steps) < 1 or len(meal_recipe.steps) > 25:
            raise ValueError(f"Invalid number of steps: {len(meal_recipe.steps)}")
        return True
