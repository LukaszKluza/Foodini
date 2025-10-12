import json
import os
import traceback
from typing import Any, Dict, List, Optional

import requests

from backend.diet_generation.enums.meal_type import MealType
from backend.diet_generation.meal_recipes_repository import MealRecipesRepository
from backend.models import Meal, MealRecipe, Ingredients, Ingredient, Step, UserDetails, UserDietPredictions
from backend.models import User
from backend.user_details.calories_prediction_repository import CaloriesPredictionRepository
from backend.user_details.user_details_repository import UserDetailsRepository
from backend.users.enums.language import Language
from backend.settings import config


class PromptService:
    def __init__(
        self,
        user_details_repo: UserDetailsRepository,
        meal_recipes_repo: MealRecipesRepository,
        calories_repo: CaloriesPredictionRepository,
    ):
        self.user_details_repo = user_details_repo
        self.meal_recipes_repo = meal_recipes_repo
        self.calories_repo = calories_repo
        self._prompt_template_cache: Optional[str] = None

    @staticmethod
    def _prepare_params(details: UserDetails, predictions: UserDietPredictions) -> dict:
        return {
            "allergens": [a.value for a in details.allergies],
            "meals_per_day": details.meals_per_day,
            "calories": predictions.target_calories,
            "macros": {
                "protein": predictions.protein,
                "carbs": predictions.carbs,
                "fat": predictions.fat
            }
        }

    @staticmethod
    def _parse_json_response(response: str) -> List[Dict[str, Any]]:
        start = response.find("[")
        end = response.rfind("]")
        if start == -1 or end == -1:
            raise ValueError("Response does not contain a JSON array")
        return json.loads(response[start:end + 1])

    async def generate_meal_plan(self, user: User, retries: int = 2) -> List[MealRecipe]:
        user_details = await self._get_user_details(user.id)
        user_predictions = await self._get_user_predictions(user.id)
        params = self._prepare_params(user_details, user_predictions)
        prompt = self._build_prompt(params)

        response = await self._get_valid_json_from_model(prompt, retries)
        return await self._save_meals(response)

    def _build_prompt(self, params: dict) -> str:
        if self._prompt_template_cache is None:
            prompt_file_path = os.path.join(os.path.dirname(__file__), config.PROMPTS_DIR, config.DAILY_MEALS_PROMPT_FILENAME)
            try:
                with open(prompt_file_path, 'r', encoding='utf-8') as f:
                    self._prompt_template_cache = f.read()
            except FileNotFoundError:
                raise RuntimeError(f"Prompt file not found at: {prompt_file_path}")

        meal_types = ", ".join(f'"{m.value}"' for m in MealType)
        return self._prompt_template_cache.format(
            input_data=json.dumps(params, indent=2, ensure_ascii=False),
            meal_type_options=meal_types
        )

    async def _get_valid_json_from_model(self, prompt: str, retries: int) -> List[Dict[str, Any]]:
        last_exception = None
        for attempt in range(retries + 1):
            try:
                resp = requests.post(config.OLLAMA_URL, json={"model": config.MODEL_NAME, "prompt": prompt, "stream": False})
                resp.raise_for_status()
                return self._parse_json_response(resp.json()["response"])
            except Exception as e:
                last_exception = e
                prompt += "\n\nWarning: Previous response was not valid JSON. Return only valid JSON."
        raise ValueError(f"Model did not return valid JSON: {last_exception}")

    async def _save_meals(self, meals_data: List[Dict[str, Any]]) -> List[MealRecipe]:
        saved_recipes = []
        print(meals_data)
        for meal_data in meals_data:
            try:

                meal = Meal(
                    meal_name=meal_data["meal_name"].capitalize(),
                    meal_type=MealType(meal_data["meal_type"].lower()),
                    icon_id=MealType(meal_data["meal_type"].lower()).meal_order
                )
                saved_meal = await self.meal_recipes_repo.add_meal(meal)

                ingredients = Ingredients(
                    ingredients=[
                        Ingredient(name=i["name"], unit=i["unit"], volume=float(i["volume"]))
                        for i in meal_data["ingredients"]
                    ]
                )
                steps = [Step(description=s) for s in meal_data.get("steps", [])]

                recipe = MealRecipe(
                    meal_id=saved_meal.id,
                    language=Language.EN,
                    meal_description=meal_data["meal_description"],
                    ingredients=ingredients.model_dump(),
                    steps=[s.model_dump() for s in steps],
                )
                saved = await self.meal_recipes_repo.add_meal_recipe(recipe)
                saved_recipes.append(saved)
            except Exception as e:
                print(traceback.format_exc())
                print(f"[ERROR] Failed to save recipe '{meal_data["meal_name"]}': {e}")
        return saved_recipes

    async def _get_user_details(self, user_id: int) -> UserDetails:
        details = await self.user_details_repo.get_user_details_by_id(user_id)
        if not details:
            raise ValueError(f"No user details found for user_id={user_id}")
        return details

    async def _get_user_predictions(self, user_id: int) -> UserDietPredictions:
        predictions = await self.calories_repo.get_user_calories_prediction_by_user_id(user_id)
        if not predictions:
            raise ValueError(f"No diet predictions found for user_id={user_id}")
        return predictions
