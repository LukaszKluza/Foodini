from sqlalchemy import select
from sqlmodel.ext.asyncio.session import AsyncSession

from backend.models import UserDietPredictions

from .schemas import PredictedCalories, PredictedMacros


class CaloriesPredictionRepository:
    def __init__(self, db: AsyncSession):
        self.db = db

    async def add_user_calories_prediction(
        self, user_id: int, predicted_calories: PredictedCalories
    ) -> PredictedCalories:
        result = await self.db.execute(select(UserDietPredictions).where(UserDietPredictions.user_id == user_id))
        user_diet_predictions = result.scalars().first()

        if user_diet_predictions:
            for key, value in predicted_calories.model_dump(exclude={"predicted_macros"}).items():
                setattr(user_diet_predictions, key, value)
            for key, value in predicted_calories.predicted_macros.model_dump().items():
                setattr(user_diet_predictions, key, value)
        else:
            user_diet_predictions = UserDietPredictions(
                user_id=user_id,
                **predicted_calories.model_dump(exclude={"predicted_macros"}),
                **predicted_calories.predicted_macros.model_dump(),
            )
            self.db.add(user_diet_predictions)

        await self.db.commit()
        await self.db.refresh(user_diet_predictions)

        return PredictedCalories(
            bmr=user_diet_predictions.bmr,
            tdee=user_diet_predictions.tdee,
            target_calories=user_diet_predictions.target_calories,
            diet_duration_days=user_diet_predictions.diet_duration_days,
            predicted_macros=PredictedMacros(
                protein=user_diet_predictions.protein, fat=user_diet_predictions.fat, carbs=user_diet_predictions.carbs
            ),
        )
        
    async def update_macros_prediction(self, changed_macros: PredictedMacros, user_id: int) -> PredictedCalories:
        result = await self.db.execute(select(UserDietPredictions).where(UserDietPredictions.user_id == user_id))
        user_diet_predictions = result.scalars().first()

        if not user_diet_predictions:
            raise ValueError("No existing calorie prediction found for the user.")

        for key, value in changed_macros.model_dump().items():
            setattr(user_diet_predictions, key, value)

        await self.db.commit()
        await self.db.refresh(user_diet_predictions)

        return PredictedCalories(
            bmr=user_diet_predictions.bmr,
            tdee=user_diet_predictions.tdee,
            target_calories=user_diet_predictions.target_calories,
            diet_duration_days=user_diet_predictions.diet_duration_days,
            predicted_macros=PredictedMacros(
                protein=user_diet_predictions.protein, fat=user_diet_predictions.fat, carbs=user_diet_predictions.carbs
            ),
        )

    async def get_user_calories_prediction_by_user_id(self, user_id: int) -> UserDietPredictions:
        query = select(UserDietPredictions).where(UserDietPredictions.user_id == user_id)
        result = await self.db.execute(query)
        return result.scalar_one_or_none()
