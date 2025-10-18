import json
import os
from datetime import date
from typing import Any, Dict, List, Optional

import requests

from backend.diet_generation.daily_summary_repository import DailySummaryRepository
from backend.diet_generation.enums.meal_type import MealType
from backend.diet_generation.meal_recipes_repository import MealRecipesRepository
from backend.diet_generation.schemas import DailyMacrosSummaryCreate, DailyMealsCreate, MealCreate, MealInfo
from backend.models import Ingredient, Ingredients, MealRecipe, Step, UserDetails, UserDietPredictions
from backend.settings import config
from backend.users.enums.language import Language


class PromptService:
    def __init__(
        self,
        meal_recipes_repo: MealRecipesRepository,
        daily_summary_repo: DailySummaryRepository,
    ):
        self.meal_recipes_repo = meal_recipes_repo
        self.daily_summary_repo = daily_summary_repo
        self._prompt_template_cache: Optional[str] = None

    @staticmethod
    def _prepare_params(details: UserDetails, predictions: UserDietPredictions) -> dict:
        return {
            "allergens": [a.value for a in details.allergies],
            "meals_per_day": details.meals_per_day,
            "calories": predictions.target_calories,
            "macros": {"protein": predictions.protein, "carbs": predictions.carbs, "fat": predictions.fat},
        }

    @staticmethod
    def _parse_json_response(response: str) -> List[Dict[str, Any]]:
        start = response.find("[")
        end = response.rfind("]")
        if start == -1 or end == -1:
            raise ValueError("Response does not contain a JSON array")
        return json.loads(response[start : end + 1])

    async def generate_meal_plan(
        self, day: date, user_details: UserDetails, user_diet_predictions: UserDietPredictions, retries: int = 2
    ) -> List[int]:
        params = self._prepare_params(user_details, user_diet_predictions)
        prompt = self._build_prompt(params)

        response = await self._get_valid_json_from_model(prompt, retries)
        return await self._save_meals(day, response, user_diet_predictions)

    def _build_prompt(self, params: dict) -> str:
        if self._prompt_template_cache is None:
            prompt_file_path = os.path.join(
                os.path.dirname(__file__), config.PROMPTS_DIR, config.DAILY_MEALS_PROMPT_FILENAME
            )
            try:
                with open(prompt_file_path, "r", encoding="utf-8") as f:
                    self._prompt_template_cache = f.read()
            except FileNotFoundError as err:
                raise RuntimeError(f"Prompt file not found at: {prompt_file_path}") from err

        meal_types = ", ".join(f'"{m.value}"' for m in MealType)
        return self._prompt_template_cache.format(
            input_data=json.dumps(params, indent=2, ensure_ascii=False), meal_type_options=meal_types
        )

    async def _get_valid_json_from_model(self, prompt: str, retries: int) -> List[Dict[str, Any]]:
        last_exception = None
        for _attempt in range(retries + 1):
            try:
                resp = requests.post(
                    config.OLLAMA_URL, json={"model": config.MODEL_NAME, "prompt": prompt, "stream": False}
                )
                resp.raise_for_status()
                return self._parse_json_response(resp.json()["response"])
            except Exception as e:
                last_exception = e
                prompt += "\n\nWarning: Previous response was not valid JSON. Return only valid JSON."
        raise ValueError(f"Model did not return valid JSON: {last_exception}")

    async def _save_meal(self, meal_data: Dict[str, Any]) -> int:
        meal = MealCreate(**meal_data)
        saved_meal = await self.meal_recipes_repo.add_meal(meal)

        return saved_meal.id

    async def _save_recipes(self, meal_id, meal_data: List[Dict[str, Any]]):
        ingredients = Ingredients(
            ingredients=[
                Ingredient(name=i["name"], unit=i["unit"], volume=float(i["volume"])) for i in meal_data["ingredients"]
            ]
        )
        steps = [Step(description=s) for s in meal_data.get("steps", [])]

        recipe = MealRecipe(
            meal_id=meal_id,
            language=Language.EN,
            meal_description=meal_data["meal_description"],
            ingredients=ingredients.model_dump(),
            steps=[s.model_dump() for s in steps],
        )
        await self.meal_recipes_repo.add_meal_recipe(recipe)

    async def _save_daily_meals(
        self, day: date, meals_data: Dict[MealType, MealInfo], user_diet_predictions: UserDietPredictions
    ):
        daily_meal = DailyMealsCreate(day=day, meals=meals_data, user_diet_predictions=user_diet_predictions)
        await self.daily_summary_repo.add_daily_meals(daily_meal, user_diet_predictions.user_id)

    async def _save_daily_macros_summary(self, day: date, user_id: int):
        daily_summary = DailyMacrosSummaryCreate(day=day)
        await self.daily_summary_repo.add_daily_macros_summary(daily_summary, user_id)

    async def _save_meals(
        self, day: date, meals_data: List[Dict[str, Any]], user_diet_predictions: UserDietPredictions
    ) -> List[int]:
        saved_meals_id = []
        saved_meals_map = {}

        for meal_data in meals_data:
            saved_meal_id = await self._save_meal(meal_data)
            saved_meals_id.append(saved_meal_id)
            saved_meals_map[MealType(meals_data["meal_type"].lower())] = MealInfo(meal_id=saved_meal_id)
            await self._save_recipes(saved_meal_id, meal_data)

        await self._save_daily_meals(day, saved_meals_map, user_diet_predictions)
        await self._save_daily_macros_summary(day, user_diet_predictions.user_id)

        return saved_meals_id
