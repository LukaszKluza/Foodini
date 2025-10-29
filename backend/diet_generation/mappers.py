from backend.diet_generation.schemas import CompleteMeal, MealRecipeTranslation, IngredientCreate, StepCreate
from backend.meals.enums.meal_type import MealType
from backend.models import Ingredient, Ingredients, Meal, MealRecipe, Step
from backend.users.enums.language import Language


def complete_meal_to_meal(meal_data: CompleteMeal) -> Meal:
    return Meal(
        meal_type=MealType(meal_data.meal_type),
        icon_id=MealType(meal_data.meal_type).order,
        calories=meal_data.calories,
        protein=meal_data.protein,
        fat=meal_data.fat,
        carbs=meal_data.carbs,
    )


def complete_meal_to_recipe(meal_data: CompleteMeal, meal_id: int, language: Language = Language.EN) -> MealRecipe:
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

def meal_recipe_translation_to_recipe(translated_recipe: MealRecipeTranslation, meal_id: int, language: Language = Language.PL) -> MealRecipe:
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
    return MealRecipeTranslation (
        meal_name=recipe.meal_name,
        meal_description=recipe.meal_description,
        ingredients_list=[IngredientCreate(**ingredient) for ingredient in recipe.ingredients["ingredients"]],
        steps=[StepCreate(**step) for step in recipe.steps],
    )