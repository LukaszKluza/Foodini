from backend.meals.enums.meal_type import MealType
from backend.diet_generation.schemas import CompleteMeal
from backend.models import Meal, MealRecipe, Ingredient, Ingredients, Step
from backend.users.enums.language import Language


def complete_meal_to_meal(meal_data: CompleteMeal) -> Meal:
    return Meal(
        meal_name=meal_data.meal_name,
        meal_type=MealType(meal_data.meal_type),
        icon_id=MealType(meal_data.meal_type).order,
        calories=meal_data.calories,
        protein=meal_data.protein,
        fat=meal_data.fat,
        carbs=meal_data.carbs,
    )

def complete_meal_to_recipe(meal_data: CompleteMeal, meal_id: int) -> MealRecipe:
    return MealRecipe(
        meal_id=meal_id,
        language=Language.EN,
        meal_description=meal_data.meal_description,
        ingredients=Ingredients(
            ingredients=[Ingredient(**i.model_dump()) for i in meal_data.ingredients_list]
        ).model_dump(),
        steps=[Step(**s.model_dump()).model_dump() for s in meal_data.steps],
    )