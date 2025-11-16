import asyncio
from datetime import date, timedelta
from typing import Dict, List
from uuid import UUID

from fastapi import HTTPException, status

from backend.core.logger import logger
from backend.core.not_found_in_database_exception import NotFoundInDatabaseException
from backend.daily_summary.daily_summary_gateway import DailySummaryGateway
from backend.daily_summary.schemas import BasicMealInfo, DailyMacrosSummaryCreate
from backend.diet_generation.agent.graph_builder import DietAgentBuilder
from backend.diet_generation.mappers import (
    complete_meal_to_meal,
    complete_meal_to_recipe,
    meal_recipe_translation_to_recipe,
    recipe_to_meal_recipe_translation,
    to_daily_meals_create,
    to_empty_basic_meal_info,
)
from backend.diet_generation.schemas import CompleteMeal, DietGenerationInput, create_agent_state
from backend.diet_generation.tools.translator import TranslatorTool
from backend.meals.enums.meal_type import MealType
from backend.meals.meal_gateway import MealGateway
from backend.models import Meal, MealRecipe, User, UserDetails, UserDietPredictions
from backend.user_details.user_details_gateway import UserDetailsGateway
from backend.users.enums.language import Language


class DailyMealsGeneratorService:
    def __init__(
        self,
        meal_gateway: MealGateway,
        daily_summary_gateway: DailySummaryGateway,
        user_details_gateway: UserDetailsGateway,
    ):
        self.meal_gateway = meal_gateway
        self.daily_summary_gateway = daily_summary_gateway
        self.user_details_gateway = user_details_gateway
        self.translator = TranslatorTool()

    @staticmethod
    def _prepare_input(
        details: UserDetails, predictions: UserDietPredictions, previous_meals: List[str]
    ) -> DietGenerationInput:
        return DietGenerationInput(
            dietary_restriction=[restriction for restriction in details.dietary_restrictions],
            meals_per_day=details.meals_per_day,
            meal_types=MealType.daily_meals(details.meals_per_day),
            calories=predictions.target_calories,
            protein=predictions.protein,
            carbs=predictions.carbs,
            fat=predictions.fat,
            previous_meals=previous_meals,
        )

    async def generate_meal_plan(self, user: User, day: date) -> List[MealRecipe]:
        try:
            user_details, user_diet_predictions, user_latest_meals, meal_icons = await self._get_required_arguments(
                user, day
            )

            input_data = self._prepare_input(user_details, user_diet_predictions, user_latest_meals)

            agent = DietAgentBuilder(user_details.meals_per_day)
            app = agent.build_graph()

            initial_state = create_agent_state(input_data)
            generated_diet = await asyncio.to_thread(lambda: app.invoke(initial_state))

            saved_meals, saved_recipes, meals_type_map = await self._save_meals(
                generated_diet.get("current_plan"), meal_icons
            )
            await self._save_daily_summary(day, user_diet_predictions, meals_type_map)
            await self._translate_and_save_recipes(saved_meals, saved_recipes)
        except NotFoundInDatabaseException:
            raise
        except HTTPException:
            raise
        except Exception as e:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=f"Error generating diet plan for user {user.id}",
            ) from e
        return saved_recipes

    async def _get_required_arguments(self, user: User, day: date):
        user_details = await self.user_details_gateway.get_user_details(user)
        user_diet_predictions = await self.user_details_gateway.get_user_diet_predictions(user)
        user_latest_meals = await self.daily_summary_gateway.get_last_generated_meals(
            user.id, day - timedelta(days=7), day
        )
        meal_types = MealType.daily_meals(user_details.meals_per_day)
        meal_icons = {meal_type.value: await self.meal_gateway.get_meal_icon_id(meal_type) for meal_type in meal_types}

        return user_details, user_diet_predictions, user_latest_meals, meal_icons

    async def _save_meals(self, daily_diet: List[CompleteMeal], meal_icons: Dict[str, UUID]):
        saved_meals = []
        saved_recipes = []
        meals_type_map = {}

        for complete_meal in daily_diet:
            saved_meal = await self.meal_gateway.add_meal(
                complete_meal_to_meal(complete_meal, meal_icons[complete_meal.meal_type])
            )
            meal_recipe = await self.meal_gateway.add_meal_recipe(
                complete_meal_to_recipe(complete_meal, saved_meal.id, Language.EN)
            )

            saved_meals.append(saved_meal)
            saved_recipes.append(meal_recipe)
            meals_type_map[saved_meal.meal_type.value] = to_empty_basic_meal_info(meal_id=saved_meal.id)

        return saved_meals, saved_recipes, meals_type_map

    async def _save_daily_summary(
        self, day: date, user_diet_predictions: UserDietPredictions, meals_type_map: Dict[MealType, BasicMealInfo]
    ):
        await self.daily_summary_gateway.add_daily_meals(
            to_daily_meals_create(day, user_diet_predictions, meals_type_map), user_diet_predictions.user_id
        )
        await self.daily_summary_gateway.add_daily_macros_summary(
            user_diet_predictions.user_id, DailyMacrosSummaryCreate(day=day)
        )

    async def _translate_and_save_recipes(self, meals: List[Meal], meal_recipes: List[MealRecipe]):
        for meal, meal_recipe in zip(meals, meal_recipes):
            try:
                translated_recipe = await asyncio.to_thread(
                    lambda _meal_recipe=meal_recipe: self.translator.translate_meal_recipe_to_polish(
                        recipe_to_meal_recipe_translation(_meal_recipe)
                    )
                )
                await self.meal_gateway.add_meal_recipe(meal_recipe_translation_to_recipe(translated_recipe, meal.id))
            # Error suppression in case of failed translation
            except Exception as e:
                logger.error(f"Error while translating recipe: {str(e)}")
                pass
