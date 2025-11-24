from backend.models import UserDetails
from backend.user_details.enums import Gender
from backend.user_details.schemas import PredictedCalories
from backend.user_details.service.macro_factory import MacroFactory


class CaloriesPredictionAlgorithm:
    def __init__(self, user_details: UserDetails) -> None:
        self.user_details = user_details
        self.bmr = 0
        self.tdee = 0
        self.target_calories = 0
        self.diet_duration_days = 0
        self.predicted_macros = None

    async def count_calories_prediction(self) -> PredictedCalories:
        self._calculate_advance_bmr() if self.user_details.fat_percentage is not None else self._calculate_bmr()
        (
            self._apply_activity()
            ._apply_stress_level()
            ._apply_sleep_quality_level()
            ._apply_intensity()
            ._add_diet_duration_to_goal()
            ._add_predicted_macros()
        )

        return PredictedCalories(
            user_id=self.user_details.user_id,
            bmr=int(self.bmr),
            tdee=int(self.tdee),
            target_calories=int(self.target_calories),
            diet_duration_days=self.diet_duration_days,
            predicted_macros=self.predicted_macros,
        )

    def _calculate_bmr(self):
        factor = 5 if self.user_details.gender == Gender.MALE else -161
        basic_bmr = 10 * self.user_details.weight_kg + 6.25 * self.user_details.height_cm - 5 * self.user_details.age
        self.bmr = basic_bmr + factor
        return self

    def _calculate_advance_bmr(self):
        lbm = self.user_details.weight_kg * (1 - self.user_details.fat_percentage / 100)
        self.bmr = 370 + (21.6 * lbm)
        return self

    def _apply_activity(self):
        self.tdee = self.bmr * self.user_details.activity_level.get_activity_factor()
        return self

    def _apply_stress_level(self):
        self.tdee = self.tdee * (1 - self.user_details.stress_level.get_stress_factor())
        return self

    def _apply_sleep_quality_level(self):
        self.tdee = self.tdee * (1 + self.user_details.sleep_quality.get_sleep_quality_factor())
        return self

    def _apply_intensity(self):
        diet_type_factor = self.user_details.diet_type.get_diet_type_factor()
        intensity = self.user_details.diet_intensity.get_intensity_factor()
        self.target_calories = self.tdee * (1 + diet_type_factor * intensity)
        return self

    def _add_diet_duration_to_goal(self):
        calories_to_goal = abs(self.user_details.diet_goal_kg - self.user_details.weight_kg) * 7700
        day_calories_diff = abs(self.target_calories - self.tdee)
        self.diet_duration_days = round(calories_to_goal / day_calories_diff) if day_calories_diff != 0 else 0
        return self

    def _add_predicted_macros(self):
        self.predicted_macros = MacroFactory.get_calculator(
            self.user_details.diet_type, self.user_details.weight_kg, self.target_calories
        ).calculate()
        return self
