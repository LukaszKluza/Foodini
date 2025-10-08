import json
import os
from typing import Any, Dict, List, Optional
import requests

from backend.diet_generation.meal_recipes_repository import MealRecipesRepository
from backend.models import MealRecipe, Ingredients, Ingredient, Step, UserDetails, UserDietPredictions
from backend.user_details.calories_prediction_repository import CaloriesPredictionRepository
from backend.user_details.user_details_repository import UserDetailsRepository
from backend.users.enums.language import Language
from backend.diet_generation.enums.meal_type import MealType
from backend.models import User

OLLAMA_URL = "http://localhost:11434/api/generate"
MODEL_NAME = "qwen3:30b"
PROMPT_FILE_PATH = os.path.join(os.path.dirname(__file__), "prompts", "daily_meals_generator_prompt.txt")

class PromptService:
    def __init__(
            self,
            user_details_repository: UserDetailsRepository,
            meal_recipes_repository: MealRecipesRepository,
            calories_prediction_repository: CaloriesPredictionRepository,
    ):
        self.user_details_repository = user_details_repository
        self.meal_recipes_repository = meal_recipes_repository
        self.calories_prediction_repository = calories_prediction_repository

    _prompt_template_cache: Optional[str] = None

    def _get_prompt_template(self) -> str:
        if self._prompt_template_cache is None:
            try:
                with open(PROMPT_FILE_PATH, 'r', encoding='utf-8') as f:
                    self._prompt_template_cache = f.read()
            except FileNotFoundError:
                raise RuntimeError(f"Prompt file not found at: {PROMPT_FILE_PATH}")

        return self._prompt_template_cache

    def _build_prompt(self, params: Dict[str, Any]) -> str:
        meal_type_values = [m.value for m in MealType]
        meal_type_str = ", ".join(f'"{m}"' for m in meal_type_values)

        input_data_json = json.dumps(params, indent=2, ensure_ascii=False)

        prompt_template = self._get_prompt_template()

        return prompt_template.format(
            input_data=input_data_json,
            meal_type_options=meal_type_str
        )

    def _query_ollama(self, prompt: str) -> str:
        resp = requests.post(OLLAMA_URL, json={"model": MODEL_NAME, "prompt": prompt, "stream": False})
        resp.raise_for_status()
        return resp.json()["response"]

    def _parse_json_response(self, response: str) -> List[Dict[str, Any]]:
        start = response.find("[")
        end = response.rfind("]")
        if start != -1 and end != -1:
            response = response[start: end + 1]
        return json.loads(response)

    async def _add_meal_recipe(self, meal_recipe: MealRecipe) -> MealRecipe:
        return await self.meal_recipes_repository.add_meal_recipe(meal_recipe)

    async def _prepare_generation_params(self, user_details: UserDetails, user_predictions: UserDietPredictions) -> Dict[str, Any]:
        return {
            "allergens": [a.value for a in user_details.allergies],
            "meals_per_day": user_details.meals_per_day,
            "calories": user_predictions.target_calories,
            "macros": {
                "protein": user_predictions.protein,
                "carbs": user_predictions.carbs,
                "fat": user_predictions.fat
            }
        }

    async def generate_meal_plan(self, user: User, retries: int = 2) -> List[MealRecipe]:
        user_details = await self.user_details_repository.get_user_details_by_id(user.id)
        user_predictions = await self.calories_prediction_repository.get_user_calories_prediction_by_user_id(user.id)
        params = await self._prepare_generation_params(user_details, user_predictions)
        prompt = self._build_prompt(params)

        for attempt in range(retries + 1):
            try:
                response = self._query_ollama(prompt)
                print(response)
                parsed_meals = self._parse_json_response(response)
                break
            except Exception as e:
                print(f"[WARN] JSON parse failed (attempt {attempt + 1}): {e}")
                prompt += "\n\nWarning: Previous response was not valid JSON. Return only valid JSON."
        else:
            raise ValueError("Model did not return valid JSON after several attempts.")

        created_recipes: List[MealRecipe] = []
        for meal_data in parsed_meals:
            try:
                ingredients_obj = Ingredients(
                    ingredients=[
                        Ingredient(name=i["name"], unit=i["unit"], volume=float(i["volume"]))
                        for i in meal_data["ingredients"]
                    ]
                )
                steps_objects = [Step(description=s) for s in meal_data.get("steps", [])]

                recipe = MealRecipe(
                    language=Language.EN,
                    meal_name=meal_data["meal_name"].capitalize(),
                    meal_type=MealType(meal_data["meal_type"].lower()),
                    meal_description=meal_data["meal_description"],
                    icon_id=MealType(meal_data["meal_type"].lower()).meal_order,

                    ingredients=ingredients_obj.model_dump(),

                    steps=[s.model_dump() for s in steps_objects],
                )

                saved = await self._add_meal_recipe(recipe)
                created_recipes.append(saved)
            except Exception as e:
                print(f"[ERROR] Failed to save recipe: {e}")

        return created_recipes