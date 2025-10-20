import json
import os
from datetime import date
from typing import Any, Dict, List, Optional

from ollama import Client

from backend.diet_generation.daily_summary_repository import DailySummaryRepository
from backend.diet_generation.enums.meal_type import MealType
from backend.diet_generation.meal_recipes_repository import MealRecipesRepository
from backend.diet_generation.schemas import DailyMacrosSummaryCreate, DailyMealsCreate, MealCreate, MealInfo
from backend.models import Ingredient, Ingredients, MealRecipe, Step, UserDetails, UserDietPredictions
from backend.settings import config
from backend.user_details.schemas import PredictedCalories
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
    def _prepare_params(details: UserDetails, predictions: PredictedCalories) -> dict:
        return {
            "allergens": [a.value for a in details.allergies],
            "meals_per_day": details.meals_per_day,
            "calories": predictions.target_calories,
            "macros": {
                "protein": predictions.predicted_macros.protein,
                "carbs": predictions.predicted_macros.carbs,
                "fat": predictions.predicted_macros.fat,
            },
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
            # try:
            # headers = {
            #     "Authorization": f"Bearer 27067041099a4d0b85375bf46722ce24.VkE50bIx_4EdiU_jTKs3zrkq",
            #     "Content-Type": "application/json",
            # }
            # resp = requests.post(
            #     "https://api.ollama.com/v1/generate", headers=headers, json={"model": "deepseek-v3.1:671b-cloud",
            #                                                                  "prompt": prompt,
            #                                                  "stream": False}
            # )

            prompt = [
                {"role": "system", "content": "You are an AI dietitian. Your task is to generate a one-day meal plan."},
                {
                    "role": "user",
                    "content": """
                Here's Input data:
                {
                  "allergens": ["lactose", "meat"],
                  "meals_per_day": 5,
                  "calories": 2253,
                  "macros": {"protein": 98, "carbs": 296, "fat": 75}
                }
    
                Generate a list of meals in pure JSON (array of objects).
                The output must be valid JSON only, without any additional text.
    
                Important requirements:
                - The sum of all meal calories must exactly match the daily calorie target (±1% margin).
                - The sum of protein, carbs, and fat across all meals must exactly match the target macros (±1g margin).
                - Each meal must have realistic macro proportions.
                - The number of meals must equal `meals_per_day` — no more, no less.
    
                Each meal must contain:
                - "meal_name": simple name of the meal
                - "meal_type": one of ["breakfast","morning_snack","lunch","afternoon_snack","dinner","evening_snack"]
                - "meal_description": short description of the meal
                - "calories": total calories for the meal
                - "macros": {"protein": int, "carbs": int, "fat": int}
                - "ingredients": list of objects {"name": string, "unit": string, "volume": float}
                - "steps": list of preparation steps (strings)
                """,
                },
            ]

            client = Client(host="https://ollama.com", headers={"Authorization": "Bearer tajny-token"})
            resp = client.chat("qwen3-coder:480b-cloud", messages=prompt, stream=False)
            print(resp)

            resp.raise_for_status()
            return self._parse_json_response(resp.json()["response"])
            # except Exception as e:
            #     last_exception = e
            #     prompt += "\n\nWarning: Previous response was not valid JSON. Return only valid JSON."
        # raise ValueError(f"Model did not return valid JSON: {last_exception}")

    async def _save_meal(self, meal_data: Dict[str, Any]) -> int:
        meal = MealCreate(**meal_data)
        saved_meal = await self.meal_recipes_repo.add_meal(meal)

        return saved_meal.id

    async def _save_recipes(self, meal_id, meal_data: Dict[str, Any]):
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
