from datetime import date
from typing import Dict, List, Type
from uuid import UUID

from backend.core.not_found_in_database_exception import NotFoundInDatabaseException
from backend.daily_summary.enums.meal_status import MealStatus
from backend.daily_summary.repositories.daily_summary_repository import DailySummaryRepository
from backend.daily_summary.repositories.last_generated_meals_repository import LastGeneratedMealsRepository
from backend.daily_summary.schemas import (
    BasicMealInfo,
    CustomMealUpdateRequest,
    DailyMacrosSummaryCreate,
    DailyMealsCreate,
    DailySummary,
    MealInfo,
    MealInfoUpdateRequest,
    MealInfoWithIconPath,
)
from backend.meals.enums.meal_type import MealType
from backend.meals.meal_gateway import MealGateway
from backend.meals.repositories.meal_repository import MealRepository
from backend.meals.schemas import MealCreate
from backend.models import DailyMealsSummary, Ingredient, Ingredients, MealRecipe, User


class DailySummaryService:
    def __init__(
        self,
        summary_repo: DailySummaryRepository,
        meal_repo: MealRepository,
        last_generated_meals_repo: LastGeneratedMealsRepository,
        meal_gateway: MealGateway,
    ):
        self.daily_summary_repo = summary_repo
        self.meal_repo = meal_repo
        self.last_generated_meals_repo = last_generated_meals_repo
        self.meal_gateway = meal_gateway

    async def get_daily_summary(self, user: Type[User], day: date):
        daily_meals = await self.daily_summary_repo.get_daily_summary(user.id, day, user.language)
        if not daily_meals:
            raise NotFoundInDatabaseException("Plan for given user and day does not exist.")

        meals_dict: Dict[MealType, List[MealInfoWithIconPath]] = {}

        for link in daily_meals.daily_meals:
            meal_items_info: List[MealInfoWithIconPath] = []

            for item in link.meal_items:
                meal = item.meal
                if not meal or not meal.recipes:
                    continue

                recipe = meal.recipes[0]

                meal_items_info.append(
                    MealInfoWithIconPath(
                        meal_id=meal.id,
                        status=link.status,
                        name=recipe.meal_name,
                        description=recipe.meal_description,
                        explanation=recipe.meal_explanation,
                        icon_path=await self.meal_gateway.get_meal_icon_path_by_id(meal.icon_id),
                        calories=int(meal.calories),
                        protein=float(meal.protein),
                        carbs=float(meal.carbs),
                        fat=float(meal.fat),
                        weight=item.weight_eaten if item.weight_eaten is not None else int(meal.weight),
                    )
                )

            meals_dict[link.meal_type] = meal_items_info

        macros_summary = await self.get_daily_macros_summary(user.id, day)

        return DailySummary(
            day=daily_meals.day,
            meals=meals_dict,
            target_calories=daily_meals.target_calories,
            target_protein=daily_meals.target_protein,
            target_carbs=daily_meals.target_carbs,
            target_fat=daily_meals.target_fat,
            eaten_calories=macros_summary.calories,
            eaten_protein=macros_summary.protein,
            eaten_carbs=macros_summary.carbs,
            eaten_fat=macros_summary.fat,
        )

    async def add_daily_meals(self, daily_meals_data: DailyMealsCreate, user_id: UUID):
        daily_meals = await self.daily_summary_repo.get_daily_meals_summary(user_id, daily_meals_data.day)
        if daily_meals:
            await self.daily_summary_repo.update_daily_meals(user_id, daily_meals_data, daily_meals_data.day)
        else:
            await self.daily_summary_repo.add_daily_meals_summary(daily_meals_data, user_id)

        daily_meals = await self.daily_summary_repo.get_daily_meals_summary(user_id, daily_meals_data.day)

        meals_dict: Dict[MealType, List[BasicMealInfo]] = {}

        for link in daily_meals.daily_meals:
            meal_items_info: List[BasicMealInfo] = []

            for item in link.meal_items:
                meal = item.meal

                basic_info = BasicMealInfo(
                    meal_id=meal.id,
                    status=link.status,
                    calories=int(meal.calories),
                    protein=float(meal.protein),
                    carbs=float(meal.carbs),
                    fat=float(meal.fat),
                    weight=item.weight_eaten if item.weight_eaten is not None else meal.weight,
                )

                meal_items_info.append(basic_info)

            meals_dict[link.meal_type] = meal_items_info

        return DailyMealsCreate(
            day=daily_meals.day,
            meals=meals_dict,
            target_calories=daily_meals.target_calories,
            target_protein=float(daily_meals.target_protein),
            target_carbs=float(daily_meals.target_carbs),
            target_fat=float(daily_meals.target_fat),
        )

    async def get_daily_meals(self, user_id: UUID, day: date):
        daily_meals = await self.daily_summary_repo.get_daily_meals_summary(user_id, day)
        if not daily_meals:
            raise NotFoundInDatabaseException("Plan for given user and day does not exist.")

        meals_dict: Dict[MealType, List[MealInfoWithIconPath]] = {}

        for link in daily_meals.daily_meals:
            meal_items_info: List[MealInfoWithIconPath] = []

            for item in link.meal_items:
                meal = item.meal
                if not meal or not meal.recipes:
                    continue

                recipe = meal.recipes[0]

                meal_items_info.append(
                    MealInfoWithIconPath(
                        meal_id=meal.id,
                        status=link.status,
                        name=recipe.meal_name,
                        description=recipe.meal_description,
                        explanation=recipe.meal_explanation,
                        icon_path=await self.meal_gateway.get_meal_icon_path_by_id(meal.icon_id),
                        calories=int(meal.calories),
                        protein=float(meal.protein),
                        carbs=float(meal.carbs),
                        fat=float(meal.fat),
                        weight=item.weight_eaten if item.weight_eaten is not None else int(meal.weight),
                    )
                )

            meals_dict[link.meal_type] = meal_items_info

        return DailyMealsCreate(
            day=daily_meals.day,
            meals=meals_dict,
            target_calories=daily_meals.target_calories,
            target_protein=daily_meals.target_protein,
            target_carbs=daily_meals.target_carbs,
            target_fat=daily_meals.target_fat,
        )

    async def add_daily_macros_summary(self, user_id: UUID, data: DailyMacrosSummaryCreate):
        daily_macros_summary = await self.daily_summary_repo.get_daily_macros_summary(user_id, data.day)
        if daily_macros_summary:
            return await self.daily_summary_repo.update_daily_macros_summary(user_id, data, data.day)
        return await self.daily_summary_repo.add_daily_macros_summary(data, user_id)

    async def get_daily_macros_summary(self, user_id: UUID, day: date):
        macros_summary = await self.daily_summary_repo.get_daily_macros_summary(user_id, day)
        if not macros_summary:
            raise NotFoundInDatabaseException("Plan for given user and day does not exist.")
        return macros_summary

    async def get_last_generated_meals(self, user_id: UUID, from_date: date, to_date: date) -> List[str]:
        return await self.last_generated_meals_repo.get_last_generated_meals(user_id, from_date, to_date)

    async def update_meal_status(self, user: Type[User], update_meal_data: MealInfoUpdateRequest):
        day = update_meal_data.day
        meal_type = update_meal_data.meal_type
        new_status = update_meal_data.status

        user_daily_meals = await self.daily_summary_repo.get_daily_meals_summary(user.id, day)
        if not user_daily_meals:
            raise NotFoundInDatabaseException("Plan for given user and day does not exist.")

        slot = next((slot for slot in user_daily_meals.daily_meals if slot.meal_type == meal_type), None)
        if not slot:
            raise NotFoundInDatabaseException("Meal does not exist in user's plan for the given day.")

        if not slot.meal_items:
            raise NotFoundInDatabaseException("No composed meals assigned to this meal slot.")

        previous_status = slot.status

        total_calories = 0
        total_protein = 0
        total_carbs = 0
        total_fat = 0

        for item in slot.meal_items:
            meal = item.meal
            if not meal:
                continue
            weight_multiplier = (item.weight_eaten or meal.weight) / meal.weight

            total_calories += meal.calories * weight_multiplier
            total_protein += meal.protein * weight_multiplier
            total_carbs += meal.carbs * weight_multiplier
            total_fat += meal.fat * weight_multiplier

        meal_info = BasicMealInfo(
            status=new_status,
            calories=int(total_calories),
            protein=float(total_protein),
            carbs=float(total_carbs),
            fat=float(total_fat),
            meal_id=slot.meal_items[0].meal_id,
            weight=slot.meal_items[0].meal.weight,
        )

        await self.daily_summary_repo.update_meal_status(user.id, day, meal_type, new_status)
        await self._update_macros_after_status_change(user.id, day, meal_info, new_status, previous_status)
        await self._update_next_meal_status(user_daily_meals)

        return meal_info

    # ruff: noqa: C901
    async def add_custom_meal(self, user: Type[User], custom_meal: CustomMealUpdateRequest):
        day = custom_meal.day
        daily_meals = await self.daily_summary_repo.get_daily_summary(user.id, day, user.language)
        if not daily_meals:
            raise NotFoundInDatabaseException("Plan for given user and day does not exist.")

        daily_meals.daily_meals = list(daily_meals.daily_meals)

        existing_link = None
        existing_item = None

        if custom_meal.meal_id:
            for link in daily_meals.daily_meals:
                for item in link.meal_items:
                    if item.meal_id == custom_meal.meal_id:
                        existing_link = link
                        existing_item = item
                        break
                if existing_link:
                    break

            if not existing_item:
                raise NotFoundInDatabaseException(f"No meal of id {custom_meal.meal_id} for this day.")

            previous_status = MealStatus(existing_link.status)
            existing_meal = existing_item.meal

        else:
            # Jeśli meal_id nie ma to dodajemy nowy posiłek do konkretnego meal_type
            # Nie testowane. Front wysyła id na razie zawsze
            existing_link = next(
                (link for link in daily_meals.daily_meals if link.meal_type == custom_meal.meal_type),
                None,
            )

            if not existing_link:
                raise NotFoundInDatabaseException(f"No meal type {custom_meal.meal_type} found for this day.")

            previous_status = MealStatus(existing_link.status)
            existing_meal = None

        new_meal = MealCreate(
            meal_type=existing_link.meal_type,
            icon_id=existing_meal.icon_id if existing_meal else None,
            calories=custom_meal.custom_calories or (existing_meal.calories if existing_meal else 0),
            protein=custom_meal.custom_protein or (existing_meal.protein if existing_meal else 0),
            carbs=custom_meal.custom_carbs or (existing_meal.carbs if existing_meal else 0),
            fat=custom_meal.custom_fat or (existing_meal.fat if existing_meal else 0),
            weight=custom_meal.custom_weight or (existing_meal.weight if existing_meal else 0),
        )

        new_meal = await self.meal_repo.add_meal(new_meal)

        if custom_meal.custom_name:
            new_name = custom_meal.custom_name
        elif existing_meal and existing_meal.recipes:
            new_name = existing_meal.recipes[0].meal_name
        else:
            new_name = "Custom Meal"

        await self.meal_gateway.add_meal_recipe(
            MealRecipe(
                meal_id=new_meal.id,
                language=user.language,
                meal_name=new_name,
                meal_description="",
                ingredients=Ingredients(ingredients=[Ingredient(volume=0, unit="", name="")]).model_dump(),
                steps=[],
            )
        )

        meal_info = MealInfo(
            status=previous_status,
            name=new_name,
            description="",
            calories=new_meal.calories,
            protein=new_meal.protein,
            carbs=new_meal.carbs,
            fat=new_meal.fat,
            weight=new_meal.weight,
            meal_id=new_meal.id,
        )

        # Jeśli istniejący był zjedzony to aktualizujemy makro
        if previous_status == MealStatus.EATEN and existing_meal:
            updated_macros = DailyMacrosSummaryCreate(
                day=day,
                calories=meal_info.calories - existing_meal.calories,
                protein=meal_info.protein - existing_meal.protein,
                carbs=meal_info.carbs - existing_meal.carbs,
                fat=meal_info.fat - existing_meal.fat,
            )
            await self._update_daily_macros_summary(user.id, updated_macros)

        # Usuwamy stary z ComposedMealItem (to do aktualizacji)
        if existing_item:
            await self.daily_summary_repo.remove_meal_from_summary(user.id, day, existing_item.meal_id)

        # Dodajemy do ComposedMealItem
        await self.daily_summary_repo.add_custom_meal(user.id, day, custom_meal.meal_type, {new_meal.id: meal_info})

        return meal_info

    async def add_meal_details(self, meal_data: MealCreate):
        return await self.meal_repo.add_meal(meal_data)

    async def get_meal_details(self, meal_id: UUID):
        meal = await self.meal_repo.get_meal_by_id(meal_id)
        if not meal:
            raise NotFoundInDatabaseException(f"Meal with id {meal_id} not found.")
        return meal

    async def _get_meal_calories(self, meal_id: UUID) -> int:
        calories = await self.meal_repo.get_meal_calories_by_id(meal_id)
        if calories is None:
            raise NotFoundInDatabaseException(f"Meal with id {meal_id} not found.")
        return calories

    async def _get_meal_macros(self, meal_id: UUID):
        protein = await self.meal_repo.get_meal_protein_by_id(meal_id)
        fat = await self.meal_repo.get_meal_fat_by_id(meal_id)
        carbs = await self.meal_repo.get_meal_carbs_by_id(meal_id)

        if None in (protein, fat, carbs):
            raise NotFoundInDatabaseException(f"Meal with id {meal_id} not found.")
        return {
            "protein": protein,
            "fat": fat,
            "carbs": carbs,
        }

    async def _update_daily_macros_summary(self, user_id: UUID, data: DailyMacrosSummaryCreate):
        user_daily_macros = await self.daily_summary_repo.get_daily_macros_summary(user_id, data.day)
        if not user_daily_macros:
            raise NotFoundInDatabaseException("Plan for given user and day does not exist.")

        data.calories += user_daily_macros.calories
        data.protein += user_daily_macros.protein
        data.carbs += user_daily_macros.carbs
        data.fat += user_daily_macros.fat

        await self.daily_summary_repo.update_daily_macros_summary(user_id, data, data.day)
        return user_daily_macros

    async def _update_macros_after_status_change(
        self, user_id: UUID, day: date, meal_info: BasicMealInfo, status: MealStatus, previous_status: MealStatus
    ):
        multiplier = 0

        if status == MealStatus.EATEN and previous_status != MealStatus.EATEN:
            multiplier = 1
        elif status != MealStatus.EATEN and previous_status == MealStatus.EATEN:
            multiplier = -1

        if multiplier == 0:
            return

        calories = meal_info.calories
        protein = meal_info.protein
        carbs = meal_info.carbs
        fat = meal_info.fat
        meal_id = meal_info.meal_id

        if None in (calories, protein, carbs, fat) and meal_id:
            db_calories = await self._get_meal_calories(meal_id)
            db_macros = await self._get_meal_macros(meal_id)
            calories = calories if calories is not None else db_calories
            protein = protein if protein is not None else db_macros["protein"]
            carbs = carbs if carbs is not None else db_macros["carbs"]
            fat = fat if fat is not None else db_macros["fat"]

        calories = calories or 0
        protein = protein or 0
        carbs = carbs or 0
        fat = fat or 0

        data = DailyMacrosSummaryCreate(
            day=day,
            calories=calories * multiplier,
            protein=protein * multiplier,
            carbs=carbs * multiplier,
            fat=fat * multiplier,
        )

        await self._update_daily_macros_summary(user_id, data)

    async def _update_next_meal_status(self, user_daily_meals: DailyMealsSummary):
        all_meal_links = user_daily_meals.daily_meals
        day = user_daily_meals.day
        user_id = user_daily_meals.user_id

        sorted_meals = MealType.sorted_meals()

        target_pending_meal_link = None

        for meal_type in sorted_meals:
            link_to_check = next((link for link in all_meal_links if link.meal_type == meal_type), None)

            if not link_to_check:
                continue

            current_status = link_to_check.status

            if current_status == MealStatus.TO_EAT or current_status == MealStatus.PENDING:
                target_pending_meal_link = link_to_check
                break

        for link in all_meal_links:
            current_status = link.status
            new_status = current_status

            if link == target_pending_meal_link:
                if current_status != MealStatus.PENDING:
                    new_status = MealStatus.PENDING
                else:
                    continue
            elif current_status == MealStatus.PENDING:
                new_status = MealStatus.TO_EAT
            elif current_status == MealStatus.TO_EAT and link != target_pending_meal_link:
                continue

            if new_status != current_status:
                link.status = new_status.value
                await self.daily_summary_repo.update_meal_status(user_id, day, link.meal_type, new_status)
