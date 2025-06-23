from backend.models import UserDetails
from backend.user_details.enums import Gender
from backend.user_details.schemas import PredictedCalories


class CaloriesPredictionAlgorithm:
    def __init__(self, user_details: UserDetails) -> None:
        self.user_details = user_details
        self.bmr = 0
        self.tdee = 0
        self.target_calories = 0
        self.diet_duration_days = 0

    async def count_calories_prediction(self) -> PredictedCalories:
        (
            self.calculate_bmr()
            .apply_activity()
            .apply_stress_level()
            .apply_sleep_quality_level()
            .apply_intensity()
            .add_diet_duration_to_goal()
        )
        return PredictedCalories(
            bmr=int(self.bmr),
            tdee=int(self.tdee),
            target_calories=int(self.target_calories),
            diet_duration_days=self.diet_duration_days,
        )

    def calculate_bmr(self):
        factor = 5 if self.user_details.gender == Gender.MALE else -161
        basic_bmr = 10 * self.user_details.weight_kg + 6.25 * self.user_details.height_cm - 5 * self.user_details.age
        self.bmr = basic_bmr + factor
        return self

    def apply_activity(self):
        self.tdee = self.bmr * self.user_details.activity_level.get_activity_factor()
        return self

    def apply_stress_level(self):
        self.tdee = self.tdee * (1 - self.user_details.stress_level.get_stress_factor())
        return self

    def apply_sleep_quality_level(self):
        self.tdee = self.tdee * (1 + self.user_details.sleep_quality.get_sleep_quality_factor())
        return self

    def apply_intensity(self):
        diet_type_factor = self.user_details.diet_type.get_diet_type_factor()
        intensity = self.user_details.diet_intensity.get_intensity_factor()
        self.target_calories = self.tdee * (1 + diet_type_factor * intensity)
        return self

    def add_diet_duration_to_goal(self):
        calories_to_goal = abs(self.user_details.diet_goal_kg - self.user_details.weight_kg) * 7700
        day_calories_diff = abs(self.target_calories - self.tdee)
        self.diet_duration_days = round(calories_to_goal / day_calories_diff) if day_calories_diff != 0 else 0
        return self
