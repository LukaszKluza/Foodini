from backend.models import UserDetails
from backend.user_details.enums import Gender


class CaloriesPredictionAlgorithm:
    def __init__(self, user_details: UserDetails) -> None:
        self.user_details = user_details

    async def count_calories_prediction(self):
        bmr = await self._count_bmr()
        pal = self.user_details.activity_level.get_pal()
        tdee = bmr * pal
        return tdee

    async def _count_bmr(self):
        factor = 5 if self.user_details.gender == Gender.MALE else -161
        basic_bmr = 10 * self.user_details.weight_kg + 6.25 * self.user_details.height_cm - 5 * self.user_details.age
        return basic_bmr + factor
