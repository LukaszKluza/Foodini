import uuid

from backend.diet_generation.enums.meal_type import MealType
from backend.diet_generation.enums.unit import Unit
from backend.models import MealIcon, MealRecipe
from backend.models.meal_recipe_model import Ingredient, Ingredients, Step
from backend.users.enums.language import Language

MEAL_ICON_ID = uuid.uuid4()

MEAL_ICON = MealIcon(
    id=MEAL_ICON_ID,
    meal_type=MealType.BREAKFAST,
    icon_path="/black-coffee-fried-egg-with-toasts.jpg",
)

MEAL_ID = uuid.uuid4()
RECIPE_EN_ID = uuid.uuid4()
RECIPE_PL_ID = uuid.uuid4()

CORNFLAKES_EN_RECIPE = MealRecipe(
    id=RECIPE_EN_ID,
    meal_id=MEAL_ID,
    language=Language.EN,
    meal_name="Cornflakes with soy milk",
    meal_type=MealType.BREAKFAST,
    meal_description="Crispy cornflakes served with smooth, creamy soy milk. "
    "A light, nutritious breakfast perfect for a quick start to your day",
    icon_id=MEAL_ICON_ID,
    ingredients=Ingredients(
        ingredients=[
            Ingredient(volume=1, unit=Unit.CUP.translate(Language.EN), name="cornflakes"),
            Ingredient(
                volume=1,
                unit=Unit.CUP.translate(Language.EN),
                name="soy milk",
                optional_note="cold or warm, as preferred",
            ),
        ],
        food_additives="sugar, honey, fruits, or nut",
    ).model_dump(),
    steps=[
        s.model_dump()
        for s in [
            Step(description="Pour the cornflakes into a bowl."),
            Step(description="Add the milk over the cornflakes."),
            Step(description="Sweeten with sugar or honey.", optional=True),
            Step(description="Top with sliced fruits or nuts.", optional=True),
            Step(description="Serve immediately before it gets soggy."),
        ]
    ],
)
CORNFLAKES_PL_RECIPE = MealRecipe(
    id=RECIPE_PL_ID,
    meal_id=MEAL_ID,
    language=Language.PL,
    meal_name="Płatki kukurydziane z mlekiem sojowym",
    meal_type=MealType.BREAKFAST,
    meal_description="Chrupiące płatki kukurydziane podawane z gładkim,"
    " kremowym mlekiem sojowym. Lekkie, pożywne śniadanie idealne na szybki start dnia.",
    icon_id=MEAL_ICON_ID,
    ingredients=Ingredients(
        ingredients=[
            Ingredient(volume=1, unit=Unit.CUP.translate(Language.PL), name="płatki kukurydziane"),
            Ingredient(
                volume=1,
                unit=Unit.CUP.translate(Language.PL),
                name="mleko sojowe",
                optional_note="zimne lub ciepłe, wedle uznania",
            ),
        ],
        food_additives="cukier, miód, owoce lub orzechy",
    ).model_dump(),
    steps=[
        s.model_dump()
        for s in [
            Step(description="Wsyp płatki kukurydziane do miski."),
            Step(description="Zalej płatki mlekiem."),
            Step(description="Dosłódź cukrem lub miodem.", optional=True),
            Step(description="Posyp pokrojonymi owocami lub orzechami.", optional=True),
            Step(description="Podawaj od razu, zanim zmiękną."),
        ]
    ],
)

MEAL_RECIPES = [
    CORNFLAKES_EN_RECIPE,
    CORNFLAKES_PL_RECIPE,
]
