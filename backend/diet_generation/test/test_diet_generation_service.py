import sys
from unittest.mock import AsyncMock, MagicMock, patch

import pytest

from backend.core.not_found_in_database_exception import NotFoundInDatabaseException
from backend.diet_generation.enums.meal_type import MealType
from backend.diet_generation.test.test_data import (
    BREAKFAST_MEAL_ICON,
    MEAL_ICON_ID,
    MEAL_RECIPES,
)
from backend.models import User
from backend.users.enums.language import Language

with patch.dict(
    sys.modules,
    {
        "backend.diet_generation.meal_recipe_repository": MagicMock(),
        "backend.diet_generation.icons_repository": MagicMock(),
        "backend.diet_generation.meal_repository": MagicMock(),
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
def mock_meal_repository():
    repo = AsyncMock()
    repo.get_meal_by_id = AsyncMock()
    repo.get_meal_by_type = AsyncMock()
    return repo


@pytest.fixture
def diet_generation_service(mock_meal_icons_repository, mock_meal_repository, mock_meal_recipes_repository):
    return DietGenerationService(
        meal_icons_repository=mock_meal_icons_repository,
        meal_repository=mock_meal_repository,
        meal_recipes_repository=mock_meal_recipes_repository,
    )


basic_user = User(
    id=1,
    email="test@example.com",
)


@pytest.mark.asyncio
async def test_get_meal_icon_info_when_exist(
    diet_generation_service,
    mock_meal_icons_repository,
):
    # Given
    mock_meal_icons_repository.get_meal_icon_by_type.return_value = BREAKFAST_MEAL_ICON

    # When
    response = await diet_generation_service.get_meal_icon(MealType.BREAKFAST)

    # Then
    assert response == BREAKFAST_MEAL_ICON


@pytest.mark.asyncio
async def test_get_meal_icon_info_when_info_not_exist(
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
async def test_get_meal_recipe_by_meal_id_when_exist(
    diet_generation_service,
    mock_meal_recipes_repository,
    mock_meal_repository,
    mock_meal_icons_repository,
):
    # Given
    meal = MagicMock()
    meal.meal_type = "breakfast"
    meal.icon_id = "icon-uuid"

    icon = MagicMock()
    icon.icon_path = "path/to/icon.png"

    mock_meal_recipes_repository.get_meal_recipes_by_meal_id.return_value = MEAL_RECIPES
    mock_meal_repository.get_meal_by_id = AsyncMock(return_value=meal)
    mock_meal_icons_repository.get_meal_icon_by_id = AsyncMock(return_value=icon)

    # When
    response = await diet_generation_service.get_meal_recipes_by_meal_recipe_id("meal-uuid")

    # Then
    assert len(response) == len(MEAL_RECIPES)
    for res, recipe in zip(response, MEAL_RECIPES):
        assert res.meal_id == recipe.meal_id
        assert res.icon_path == icon.icon_path
        assert res.meal_type == meal.meal_type

    mock_meal_recipes_repository.get_meal_recipes_by_meal_id.assert_awaited_once_with("meal-uuid")
    mock_meal_repository.get_meal_by_id.assert_awaited()
    mock_meal_icons_repository.get_meal_icon_by_id.assert_awaited()


@pytest.mark.asyncio
async def test_get_meal_recipe_by_meal_id_when_not_exist(
    diet_generation_service,
    mock_meal_recipes_repository,
):
    # Given
    mock_meal_recipes_repository.get_meal_recipes_by_meal_id.return_value = None

    # When
    with pytest.raises(NotFoundInDatabaseException) as exc_info:
        await diet_generation_service.get_meal_recipes_by_meal_recipe_id(1)

    # Then
    assert exc_info.value.detail == "Meal recipes not found"


@pytest.mark.asyncio
async def test_get_meal_recipe_by_meal_recipe_id_and_language_when_exist(
    diet_generation_service,
    mock_meal_recipes_repository,
    mock_meal_repository,
    mock_meal_icons_repository,
):
    # Given
    meal_recipe = MEAL_RECIPES[0]

    meal = MagicMock()
    meal.meal_type = "breakfast"
    meal.icon_id = MEAL_ICON_ID

    icon = MagicMock()
    icon.icon_path = "path/to/icon.png"

    mock_meal_recipes_repository.get_meal_recipe_by_meal_id_and_language.return_value = meal_recipe
    mock_meal_repository.get_meal_by_id = AsyncMock(return_value=meal)
    mock_meal_icons_repository.get_meal_icon_by_id = AsyncMock(return_value=icon)

    # When
    response = await diet_generation_service.get_meal_recipe_by_meal_recipe_id_and_language(
        meal_recipe.meal_id, Language.PL
    )

    # Then
    assert response.id == meal_recipe.id
    assert response.meal_id == meal_recipe.meal_id
    assert response.language == meal_recipe.language
    assert response.meal_name == meal_recipe.meal_name
    assert response.meal_description == meal_recipe.meal_description
    assert response.meal_type == meal.meal_type
    assert response.icon_path == icon.icon_path

    mock_meal_recipes_repository.get_meal_recipe_by_meal_id_and_language.assert_awaited_once_with(
        meal_recipe.meal_id, Language.PL
    )
    mock_meal_repository.get_meal_by_id.assert_awaited_once_with(meal_recipe.meal_id)
    mock_meal_icons_repository.get_meal_icon_by_id.assert_awaited_once_with(meal.icon_id)


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
