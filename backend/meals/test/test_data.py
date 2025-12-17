import uuid

from backend.meals.enums.meal_type import MealType
from backend.meals.enums.unit import Unit
from backend.models import MealIcon, MealRecipe
from backend.models.meal_recipe_model import Ingredient, Ingredients, Step
from backend.users.enums.language import Language
from backend.users.enums.role import Role

MEAL_ICON_ID = uuid.uuid5(uuid.NAMESPACE_DNS, "meal-icon")
MEAL_ID = uuid.uuid5(uuid.NAMESPACE_DNS, "meal")
RECIPE_EN_ID = uuid.uuid5(uuid.NAMESPACE_DNS, "meal-recipe-en")
RECIPE_PL_ID = uuid.uuid5(uuid.NAMESPACE_DNS, "meal-recipe-pl")

BREAKFAST_ICON_ID = uuid.uuid5(uuid.NAMESPACE_DNS, "breakfast-icon")
MORNING_SNACK_ICON_ID = uuid.uuid5(uuid.NAMESPACE_DNS, "morning-snack-icon")
LUNCH_ICON_ID = uuid.uuid5(uuid.NAMESPACE_DNS, "lunch-icon")
AFTERNOON_SNACK_ICON_ID = uuid.uuid5(uuid.NAMESPACE_DNS, "afternoon-snack-icon")
DINNER_ICON_ID = uuid.uuid5(uuid.NAMESPACE_DNS, "dinner-icon")
EVENING_SNACK_ICON_ID = uuid.uuid5(uuid.NAMESPACE_DNS, "evening-snack-icon")

USER_ROLE_ID = uuid.uuid5(uuid.NAMESPACE_DNS, "user-role")
ADMIN_ROLE_ID = uuid.uuid5(uuid.NAMESPACE_DNS, "admin-role")

BREAKFAST_MEAL_ICON = MealIcon(
    id=BREAKFAST_ICON_ID,
    meal_type=MealType.BREAKFAST,
    icon_path="/black-coffee-fried-egg-with-toasts.webp",
)

MEAL_ICONS = [
    {"id": BREAKFAST_ICON_ID, "meal_type": MealType.BREAKFAST, "icon_path": "/black-coffee-fried-egg-with-toasts.webp"},
    {
        "id": MORNING_SNACK_ICON_ID,
        "meal_type": MealType.MORNING_SNACK,
        "icon_path": "/high-angle-tasty-breakfast-bed.webp",
    },
    {"id": LUNCH_ICON_ID, "meal_type": MealType.LUNCH, "icon_path": "/noodle-soup-winter-meals-seeds.webp"},
    {
        "id": AFTERNOON_SNACK_ICON_ID,
        "meal_type": MealType.AFTERNOON_SNACK,
        "icon_path": "/top-view-tasty-salad-with-vegetables.webp",
    },
    {
        "id": DINNER_ICON_ID,
        "meal_type": MealType.DINNER,
        "icon_path": "/seafood-salad-with-salmon-shrimp-mussels-herbs-tomatoes.webp",
    },
    {
        "id": EVENING_SNACK_ICON_ID,
        "meal_type": MealType.EVENING_SNACK,
        "icon_path": "/charcuterie-board-with-cold-cuts-fresh-fruits-cheese.webp",
    },
]

USER_ROLES = [
    {
        "id": USER_ROLE_ID,
        "name": Role.USER,
    },
    {
        "id": ADMIN_ROLE_ID,
        "name": Role.ADMIN,
    },
]

CORNFLAKES_EN_RECIPE = MealRecipe(
    id=RECIPE_EN_ID,
    meal_id=MEAL_ID,
    language=Language.EN,
    meal_name="Cornflakes with soy milk",
    meal_type=MealType.BREAKFAST,
    meal_description="Crispy cornflakes served with smooth, creamy soy milk. "
    "A light, nutritious breakfast perfect for a quick start to your day",
    meal_explanation="Meal explanation: Cornflakes with soy milk is a quick and easy breakfast option",
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
    meal_explanation="Uzasadnienie posiłku: Płatki kukurydziane z mlekiem sojowym to szybkie i łatwe do przygotowania "
    "śniadanie",
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
