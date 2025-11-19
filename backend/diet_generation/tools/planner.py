import json
from typing import Any, Dict

from langchain_core.output_parsers import JsonOutputParser
from langchain_core.prompts import PromptTemplate
from langchain_core.runnables import Runnable
from langchain_ollama import OllamaLLM

from backend.diet_generation.schemas import AgentState, CompleteMeal, DietGenerationOutput
from backend.settings import config

"""Tool used for generating and correcting output"""


class PlannerTool:
    def __init__(self):
        client_kwargs = {}
        if config.OLLAMA_API_KEY:
            client_kwargs = {"headers": {"Authorization": f"Bearer {config.OLLAMA_API_KEY}"}}

        self.llm: Runnable = OllamaLLM(
            model=config.MODEL_NAME, base_url=config.OLLAMA_API_BASE_URL, client_kwargs=client_kwargs
        )
        self.parser = JsonOutputParser(pydantic_object=DietGenerationOutput)

        self.system_instruction = (
            "You are an **AI Registered Dietitian Expert** specializing in balanced daily meal plans.\n\n"
            "### PRIMARY OBJECTIVE\n"
            "Generate or correct a **one-day meal plan** consisting of multiple meals that collectively meet "
            "the target calorie and macronutrient goals.\n\n"
            "### STRICT OUTPUT RULES\n"
            "1. Your ENTIRE output must be **pure JSON**, valid and directly parsable according to this schema:\n"
            f"{self.parser.get_format_instructions()}\n"
            "2. Do not include any text outside the JSON block.\n"
            "3. Each meal must have a **clear, realistic human meal name** that matches its type:\n"
            "- Examples: 'Oatmeal with Berries' (Breakfast), 'Grilled Chicken' (Lunch), 'Salmon with Rice' (Dinner).\n"
            "   - Avoid nonsense names, typos, or repetition like 'brreakfast', 'Meal 1', or 'Protein Plate #1'.\n"
            "4. Every meal except of correct structure must have:\n"
            "   - Ingredients that make nutritional sense.\n"
            "   - Macronutrient and calorie values that sum up correctly.\n\n"
            "### CALORIE & MACRO REQUIREMENTS\n"
            "Ensure that the **sum of all meals’ calories and macros matches exactly** the input targets.\n"
            "Calories and macros should not exceed or fall short of the targets by more than rounding error (±1%).\n"
            "If a correction is requested, modify ingredient amounts—not entire meals—to fix numeric mismatches.\n\n"
            "Respond only with valid JSON that strictly follows this schema."
        )

        self.generation_chain = PromptTemplate.from_template("{prompt_content}") | self.llm | self.parser

    """Used to add to prompt eventual correction instructions"""

    @staticmethod
    def _build_correction_prompt(state: AgentState) -> str:
        previous_json = json.dumps(
            [m.model_dump() if isinstance(m, CompleteMeal) else m for m in state.current_plan], indent=2
        )

        return f"""
        # TASK: Correct Meal Plan — Apply Provided Per-Meal Targets Exactly
        You will receive:
        1) The previously generated meal plan (JSON).
        2) A validator report that includes a machine-readable JSON block named "per_meal_targets".
           That block gives EXACT numeric targets for calories, protein (g), carbs (g), and fat (g)
           for each meal (identified by meal_index).
        ***INSTRUCTIONS (must be followed exactly):***
        1. Parse the "per_meal_targets" JSON from the validator report and apply the numeric targets for each meal.
        2. You MUST modify ONLY ingredient quantities (and meal macro/calorie numbers) so that each meal's
           calories/protein/carbs/fat equals the specified per-meal targets EXACTLY (±0.5 for grams, ±1 kcal).
        3. Do NOT add or remove meals, or rename meals, unless impossible to satisfy targets.
        4. When adjusting ingredients, ensure ingredient lists remain realistic (e.g., adjust grams/serving counts).
        5. Recalculate calories from macros if needed using: Calories = 4*(Protein + Carbs) + 9*Fat.
        6. Before returning, verify:
           - Sum of all meal calories equals global target calories.
           - Sum of all macros equals global target macros.
        7. OUTPUT: Return the full corrected meal plan as JSON ONLY — it must conform to the schema.
        PREVIOUS PLAN:
        {previous_json}
        VALIDATOR REPORT (includes per_meal_targets machine block):
        {state.validation_report}
        """

    """Used to build initial prompt"""

    @staticmethod
    def _build_initial_prompt(targets) -> str:
        return f"""
        # TASK: Initial Meal Plan Generation

        Generate a **complete one-day meal plan** that perfectly meets the provided below nutritional targets.

        ## NUTRITIONAL TARGETS
        - Calories: {targets.calories}
        - Protein: {targets.protein}g
        - Carbohydrates: {targets.carbs}g
        - Fat: {targets.fat}g
        - Meals per day: {targets.meals_per_day}
        - Diet style: {getattr(targets, "diet_style", None) or "none"}
        - Cooking skill (soft constraint): {getattr(targets, "cooking_skills", None) or "unspecified"}
        - Daily budget (soft constraint): {getattr(targets, "daily_budget", None) or "unspecified"}
        ---
        ## REQUIRED LOGIC
        Before writing JSON, **internally calculate** how to distribute the nutrients.
        Follow these steps (think silently; do not print reasoning):
        1. Divide total calories and macros evenly and logically between the meals:
           - Breakfast ≈ 25–30% of totals
           - Lunch ≈ 30–35%
           - Dinner ≈ 25–30%
           - Snacks (if any) ≈ remaining %
        2. For each meal, derive approximate calories and macros (that sum up perfectly to the targets).
        3. Ensure all generated meals are completely different to this previous meals: {
            targets.previous_meals or "None"
        }.
        4. Ensure all meal macros and calorie totals **add up exactly** to the input targets.
           - Example check: sum of all meal calories == {targets.calories} ±1 kcal
        5. Recalculate each meal’s calories from macros using:
           - Calories = 4 × (Protein + Carbs) + 9 × Fat
           Adjust slightly if needed to make the totals exact.
        ---
        ## MEAL CREATION RULES
        - Use realistic meal names that match meal types (Breakfast, Lunch, Dinner, Snack).
        - Avoid typos or generic names like “Meal 1” or “Morning food”.
        - Meals must use realistic, balanced ingredients.
        "- Meals must not include any of the following dietary restrictions: [{targets.dietary_restriction}]
        (e.g., peanuts, lactose — if any ingredient contains these allergens, it must not be used in the meal.
        For dishes containing other types of nuts, ensure they do NOT contain peanuts or traces of peanuts
        in any ingredient)."
        - Strictly follow the diet style if provided. If diet_style is:
          - vegan: absolutely no animal products (no meat, fish, dairy, eggs, honey, gelatin).
          - vegetarian: no meat or fish; dairy and eggs are allowed unless restricted elsewhere.
          - keto: keep carbohydrates very low; prioritize high fat and moderate protein ingredients.
        - Align the recipe complexity with cooking skill (softly, do not over-constrain):
          - beginner: very simple, 3–6 ingredients, few steps, common techniques (stir, bake, boil), low prep time.
          - advanced: moderate complexity, 5–10 ingredients, can include marinades/saute, reasonable prep time.
          - professional: can include advanced techniques/longer prep, but keep reasonable for a single day plan.
        - Prefer ingredients consistent with the daily budget (softly):
          - low: prioritize affordable staples (rice, beans, oats, seasonal veggies, cheaper proteins like eggs/legumes)
          - medium: mix of affordable and some premium items (chicken breast, salmon occasionally, Greek yogurt)
          - high: allow premium ingredients more freely (salmon, steak cuts, specialty produce), avoid waste.
        - Avoid using any of the user’s previous meals, new meals must be completely different: {
            targets.previous_meals or "None"
        }.
        - Meal types must match the following: {targets.meal_types}.
        - Each meal must include: name, type, ingredients, calories, protein, carbs, and fat.
        ---
        ## VALIDATION REQUIREMENT
        Double-check **before finalizing**:
        - The sum of all calories == {targets.calories}
        - The sum of all macros == {targets.protein}/{targets.carbs}/{targets.fat} grams (±1g allowed)
        - Diet style rules are not violated (e.g., vegan contains no animal-derived ingredients)
        - Meals gently reflect cooking skill and budget preferences when possible
        - Meal names are realistic and type-consistent
        - JSON is strictly valid and matches schema.
        ---

        ## OUTPUT
        Respond ONLY with the final JSON object following the schema exactly.
        """

    def generate_plan(self, state: AgentState) -> Dict[str, Any]:
        if state.correction_count == 0:
            prompt_content = self._build_initial_prompt(state.targets)
        else:
            prompt_content = self._build_correction_prompt(state)

        full_prompt = self.system_instruction + "\n\n" + prompt_content

        try:
            response_dict = self.generation_chain.invoke({"prompt_content": full_prompt})
            response_plan = DietGenerationOutput.model_validate(response_dict)

            return {
                "current_plan": response_plan.meals,
                "validation_report": None,
                "correction_count": state.correction_count + 1,
            }

        except Exception as e:
            return {
                "validation_report": f"FATAL ERROR: Diet generation error in LLM/Parser: {type(e).__name__}: {str(e)}"
            }
