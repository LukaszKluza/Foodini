from datetime import date
from typing import Dict
from uuid import UUID

from backend.daily_summary.enums.meal_status import MealStatus
from backend.daily_summary.schemas import BasicMealInfo, DailyMealsCreate
from backend.diet_generation.schemas import CompleteMeal, IngredientCreate, MealRecipeTranslation, StepCreate
from backend.meals.enums.meal_type import MealType
from backend.models import Ingredient, Ingredients, Meal, MealRecipe, Step
from backend.user_details.schemas import PredictedCalories
from backend.users.enums.language import Language


def complete_meal_to_meal(meal_data: CompleteMeal, icon_id: UUID) -> Meal:
    return Meal(
        meal_name=meal_data.meal_name,
        meal_type=MealType(meal_data.meal_type),
        icon_id=icon_id,
        calories=meal_data.calories,
        protein=meal_data.protein,
        fat=meal_data.fat,
        carbs=meal_data.carbs,
    )


def complete_meal_to_recipe(meal_data: CompleteMeal, meal_id: UUID, language: Language = Language.EN) -> MealRecipe:
    return MealRecipe(
        meal_id=meal_id,
        meal_name=meal_data.meal_name,
        language=language,
        meal_description=meal_data.meal_description,
        ingredients=Ingredients(
            ingredients=[Ingredient(**i.model_dump()) for i in meal_data.ingredients_list]
        ).model_dump(),
        steps=[Step(**s.model_dump()).model_dump() for s in meal_data.steps],
    )


def meal_recipe_translation_to_recipe(
    translated_recipe: MealRecipeTranslation, meal_id: UUID, language: Language = Language.PL
) -> MealRecipe:
    return MealRecipe(
        meal_id=meal_id,
        meal_name=translated_recipe.meal_name,
        language=language,
        meal_description=translated_recipe.meal_description,
        ingredients=Ingredients(
            ingredients=[Ingredient(**i.model_dump()) for i in translated_recipe.ingredients_list]
        ).model_dump(),
        steps=[Step(**s.model_dump()).model_dump() for s in translated_recipe.steps],
    )


def recipe_to_meal_recipe_translation(recipe: MealRecipe) -> MealRecipeTranslation:
    return MealRecipeTranslation(
        meal_name=recipe.meal_name,
        meal_description=recipe.meal_description,
        ingredients_list=[IngredientCreate(**ingredient) for ingredient in recipe.ingredients["ingredients"]],
        steps=[StepCreate(**step) for step in recipe.steps],
    )


def to_daily_meals_create(
    day: date, user_diet_predictions: PredictedCalories, meals_type_map: Dict[MealType, BasicMealInfo]
) -> DailyMealsCreate:
    return DailyMealsCreate(
        day=day,
        meals=meals_type_map,
        target_calories=user_diet_predictions.target_calories,
        target_protein=user_diet_predictions.predicted_macros.protein,
        target_fat=user_diet_predictions.predicted_macros.fat,
        target_carbs=user_diet_predictions.predicted_macros.carbs,
    )


def to_empty_basic_meal_info(meal_id: UUID, status: MealStatus = MealStatus.TO_EAT) -> BasicMealInfo:
    return BasicMealInfo(
        meal_id=meal_id,
        status=status,
        calories=0,
        protein=0,
        fat=0,
        carbs=0,
    )
