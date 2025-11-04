import json

from langchain_core.output_parsers import JsonOutputParser
from langchain_core.prompts import PromptTemplate
from langchain_core.runnables import Runnable
from langchain_ollama import OllamaLLM

from backend.diet_generation.schemas import MealRecipeTranslation
from backend.settings import config


class TranslatorTool:
    def __init__(self):
        client_kwargs = {}
        if config.OLLAMA_API_KEY:
            client_kwargs = {"headers": {"Authorization": f"Bearer {config.OLLAMA_API_KEY}"}}

        self.llm: Runnable = OllamaLLM(
            model=config.MODEL_NAME, base_url=config.OLLAMA_API_BASE_URL, client_kwargs=client_kwargs
        )
        self.parser = JsonOutputParser(pydantic_object=MealRecipeTranslation)

        self.system_instruction = (
            "You are a professional translator specialized in culinary content and Polish grammar.\n\n"
            "TASK: Translate the provided meal recipe from English to Polish in a natural, idiomatic way suitable "
            "for Polish readers.\n"
            "Your ENTIRE output must be **pure JSON**, valid and directly parsable according to this schema:\n"
            f"{self.parser.get_format_instructions()}\n"
            "QUALITY & STYLE GUIDELINES:\n"
            "- The translation could not be word-for-word; prefer fluent, natural phrasing with correct Polish grammar "
            "and diacritics.\n"
            "- Use imperative mood for steps (e.g., 'Pokrój', 'Wymieszaj', 'Podsmaż', 'Dopraw').\n"
            "- Keep units as in input (e.g., 'g', 'ml', 'cup') → do not translate them!.\n"
            "- Preserve brand names or proper nouns in original if present.\n"
            "- Ensure names and descriptions are concise, appetizing, and grammatically correct.\n"
            "STRICT INVARIANTS (must never be violated):\n"
            "1) Return ONLY valid JSON conforming EXACTLY to the TranslatedMealRecipe schema. No extra text.\n"
            "2) Do NOT change any numeric values anywhere (e.g., ingredient volumes).\n"
            "4) Translate ONLY textual content: 'meal_name', 'meal_description', each ingredient 'name' "
            "and 'optional_note', and each step 'description'.\n"
            "5) Do NOT add or remove ingredients or steps; keep counts identical.\n"
        )

        self.chain = PromptTemplate.from_template("{prompt_content}") | self.llm | self.parser

    @staticmethod
    def _build_prompt(meal_recipe: MealRecipeTranslation) -> str:
        meal_json = json.dumps(meal_recipe.model_dump(), indent=2, ensure_ascii=False)
        return f"""
                Below is a JSON object representing a meal to be translated into Polish.\n
                INPUT_MEAL_JSON:\n{meal_json}\n
                INSTRUCTIONS:\n
                - Translate textual fields into Polish.\n
                - Preserve all numeric fields exactly (do not round or recalculate).\n
                - Output ONLY the translated JSON object, strictly matching TranslatedMealRecipe schema.\n
                """

    def translate_meal_recipe_to_polish(self, meal_recipe: MealRecipeTranslation) -> MealRecipeTranslation:
        prompt = self.system_instruction + "\n\n" + self._build_prompt(meal_recipe)
        try:
            result_dict = self.chain.invoke({"prompt_content": prompt})
            return MealRecipeTranslation.model_validate(result_dict)

        except Exception as e:
            raise RuntimeError(f"Error while translating {meal_recipe.meal_name} recipe to polish") from e
