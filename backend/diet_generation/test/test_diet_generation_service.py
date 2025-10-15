import sys
from unittest.mock import AsyncMock, MagicMock, patch

import pytest

from backend.core.not_found_in_database_exception import NotFoundInDatabaseException
from backend.diet_generation.enums.meal_type import MealType
from backend.diet_generation.test.test_data import CORNFLAKES_EN_RECIPE, CORNFLAKES_PL_RECIPE, MEAL_ICON, MEAL_RECIPES
from backend.models import User
from backend.users.enums.language import Language

with patch.dict(
    sys.modules,
    {
        "backend.diet_generation.meal_recipe_repository": MagicMock(),
        "backend.diet_generation.icons_repository": MagicMock(),
    },
):
    from backend.diet_generation.diet_generation_service import DietGenerationService


@pytest.fixture
def mock_meal_icons_repository():
    repo = AsyncMock()
    repo.get_meal_icon_by_id = AsyncMock()
    repo.get_meal_icon_by_type = AsyncMock()
    return repo


@pytest.fixture
def mock_meal_recipes_repository():
    repo = AsyncMock()
    repo.get_meal_recipe_by_recipe_id = AsyncMock()
    repo.get_meal_recipes_by_meal_id = AsyncMock()
    repo.get_meal_recipe_by_meal_id_and_language = AsyncMock()
    repo.add_meal_recipe = AsyncMock()
    return repo


@pytest.fixture
def diet_generation_service(mock_meal_icons_repository, mock_meal_recipes_repository):
    return DietGenerationService(
        meal_icons_repository=mock_meal_icons_repository, meal_recipes_repository=mock_meal_recipes_repository
    )


basic_user = User(
    id=1,
    email="test@example.com",
)


@pytest.mark.asyncio
async def test_get_get_meal_icon_info_when_exist(
    diet_generation_service,
    mock_meal_icons_repository,
):
    # Given
    mock_meal_icons_repository.get_meal_icon_by_type.return_value = MEAL_ICON

    # When
    response = await diet_generation_service.get_meal_icon(MealType.BREAKFAST)

    # Then
    assert response == MEAL_ICON


@pytest.mark.asyncio
async def test_get_get_meal_icon_info_when_info_not_exist(
    diet_generation_service,
    mock_meal_icons_repository,
):
    # Given
    mock_meal_icons_repository.get_meal_icon_by_type.return_value = None

    # When
    with pytest.raises(NotFoundInDatabaseException) as exc_info:
        await diet_generation_service.get_meal_icon(MealType.DINNER)

    # Then
    assert exc_info.value.detail == "Meal icon not found"


@pytest.mark.asyncio
async def test_get_meal_recipe_by_recipe_id_when_exist(
    diet_generation_service,
    mock_meal_recipes_repository,
):
    # Given
    mock_meal_recipes_repository.get_meal_recipe_by_recipe_id.return_value = CORNFLAKES_EN_RECIPE

    # When
    response = await diet_generation_service.get_meal_recipe_by_recipe_id(1)

    # Then
    assert response == CORNFLAKES_EN_RECIPE


@pytest.mark.asyncio
async def test_get_meal_recipe_by_recipe_id_when_not_exist(
    diet_generation_service,
    mock_meal_recipes_repository,
):
    # Given
    mock_meal_recipes_repository.get_meal_recipe_by_recipe_id.return_value = None

    # When
    with pytest.raises(NotFoundInDatabaseException) as exc_info:
        await diet_generation_service.get_meal_recipe_by_recipe_id(1)

    # Then
    assert exc_info.value.detail == "Meal recipe not found"


@pytest.mark.asyncio
async def test_get_meal_recipe_by_meal_id_when_exist(
    diet_generation_service,
    mock_meal_recipes_repository,
):
    # Given
    mock_meal_recipes_repository.get_meal_recipe_by_recipe_id.return_value = MEAL_RECIPES

    # When
    response = await diet_generation_service.get_meal_recipes_by_meal_recipe_id(1)

    # Then
    assert response == MEAL_RECIPES


@pytest.mark.asyncio
async def test_get_meal_recipe_by_meal_id_when_not_exist(
    diet_generation_service,
    mock_meal_recipes_repository,
):
    # Given
    mock_meal_recipes_repository.get_meal_recipe_by_recipe_id.return_value = None

    # When
    with pytest.raises(NotFoundInDatabaseException) as exc_info:
        await diet_generation_service.get_meal_recipes_by_meal_recipe_id(1)

    # Then
    assert exc_info.value.detail == "Meal recipes not found"


@pytest.mark.asyncio
async def test_get_meal_recipe_by_meal_recipe_id_and_language_when_exist(
    diet_generation_service,
    mock_meal_recipes_repository,
):
    # Given
    mock_meal_recipes_repository.get_meal_recipe_by_meal_id_and_language.return_value = CORNFLAKES_PL_RECIPE

    # When
    response = await diet_generation_service.get_meal_recipe_by_meal_recipe_id_and_language(1, Language.PL)

    # Then
    assert response == CORNFLAKES_PL_RECIPE


@pytest.mark.asyncio
async def test_get_meal_recipe_by_meal_recipe_id_and_language_when_not_exist(
    diet_generation_service,
    mock_meal_recipes_repository,
):
    # Given
    mock_meal_recipes_repository.get_meal_recipe_by_meal_id_and_language.return_value = None

    # When
    with pytest.raises(NotFoundInDatabaseException) as exc_info:
        await diet_generation_service.get_meal_recipe_by_meal_recipe_id_and_language(1, Language.PL)

    # Then
    assert exc_info.value.detail == "Meal recipe not found"
