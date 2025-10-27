from datetime import date
from typing import List

from backend.daily_summary.daily_summary_gateway import DailySummaryGateway
from backend.daily_summary.schemas import MealInfo, DailyMealsCreate, DailyMacrosSummaryCreate
from backend.diet_generation.agent.graph_builder import DietAgentBuilder
from backend.diet_generation.mappers import complete_meal_to_meal, complete_meal_to_recipe
from backend.meals.meal_gateway import MealGateway
from backend.diet_generation.schemas import  Input, create_agent_state, CompleteMeal
from backend.models import UserDetails, UserDietPredictions, Meal, User
from backend.user_details.user_details_gateway import UserDetailsGateway


class PromptService:
    def __init__(
        self,
        meal_gateway: MealGateway,
        daily_summary_gateway: DailySummaryGateway,
        user_details_gateway: UserDetailsGateway,
    ):
        self.meal_gateway = meal_gateway
        self.daily_summary_gateway = daily_summary_gateway
        self.user_details_gateway = user_details_gateway

    @staticmethod
    def _prepare_input(details: UserDetails, predictions: UserDietPredictions) -> Input:
        return Input(
            allergens=[allergy for allergy in details.allergies],
            meals_per_day=details.meals_per_day,
            calories=predictions.target_calories,
            protein=predictions.protein,
            carbs=predictions.carbs,
            fat=predictions.fat,
            # tydzień do tyłu
            previous_meals=None
        )

    async def generate_meal_plan(
        self, user: User, day: date
    ) -> List[Meal]:
        user_details = await self.user_details_gateway.get_user_details(user)
        user_diet_predictions = await self.user_details_gateway.get_user_diet_predictions(user)
        input_data = self._prepare_input(user_details, user_diet_predictions)

        agent = DietAgentBuilder()
        app = agent.build_graph()

        initial_state = create_agent_state(input_data)

        generated_diet = app.invoke(initial_state)

        #TODO: only for test purposes ~ remove later

        # if generated_diet.get('validation_report') == 'OK' and generated_diet.get('current_plan'):
        #     print("STATUS: SUCCESS. Plan meets all the requirements.")
        #     final_plan = [meal for meal in generated_diet['current_plan']]
        #     print(json.dumps(final_plan, indent=2, default=str))
        # else:
        #     print("STATUS: FAILURE or ERROR.")
        #     print(f"Last ERROR: {generated_diet.get('validation_report')}")
        #     if generated_diet.get('current_plan'):
        #         print(f"Last generated plan:")
        #         print(json.dumps(generated_diet['current_plan'], indent=2, default=str))

        return await self._save_meals(day, user_diet_predictions, generated_diet.get('current_plan'))

    async def _save_meals(self, day: date, user_diet_predictions: UserDietPredictions, daily_diet: List[CompleteMeal]) -> List[Meal]:
        saved_meals = []
        meals_type_map = {}

        for complete_meal in daily_diet:
            saved_meal = await self.meal_gateway.add_meal(complete_meal_to_meal(complete_meal))
            await self.meal_gateway.add_meal_recipe(complete_meal_to_recipe(complete_meal, saved_meal.id))

            saved_meals.append(saved_meal)
            meals_type_map[saved_meal.meal_type.value] = MealInfo(meal_id=saved_meal.id)

        daily_meals = DailyMealsCreate(
            day=day,
            meals=meals_type_map,
            target_calories=user_diet_predictions.target_calories,
            target_protein=user_diet_predictions.protein,
            target_fats=user_diet_predictions.fat,
            target_carbs=user_diet_predictions.carbs
        )

        await self.daily_summary_gateway.add_daily_meals(daily_meals, user_diet_predictions.user_id)
        await self.daily_summary_gateway.add_daily_macros_summary(DailyMacrosSummaryCreate(day=day), user_diet_predictions.user_id)

        return saved_meals