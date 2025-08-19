from sqlalchemy import select
from sqlmodel.ext.asyncio.session import AsyncSession

from backend.models import UserDietPredictions

from .schemas import PredictedCalories

  
class CaloriesPredictionRepository:
    def __init__(self, db: AsyncSession):
        self.db = db
        
    async def add_user_calories_prediction(
        self, user_id: int, predicted_calories: PredictedCalories
    ) -> UserDietPredictions:
        user_diet_predictions = UserDietPredictions(
            user_id=user_id,
            **predicted_calories.model_dump(exclude={"predicted_macros"}),
            **predicted_calories.predicted_macros.model_dump(),
        )
        self.db.add(user_diet_predictions)
        await self.db.commit()
        await self.db.refresh(user_diet_predictions)
        return user_diet_predictions
    
    async def get_user_calories_prediction_by_user_id(self, user_id: int) -> UserDietPredictions:
        query = select(UserDietPredictions).where(UserDietPredictions.user_id == user_id)
        result = await self.db.execute(query)
        return result.scalar_one_or_none()
        