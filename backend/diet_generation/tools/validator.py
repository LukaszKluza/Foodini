import json
from typing import Any, Dict, List

from backend.diet_generation.schemas import AgentState, CompleteMeal
from backend.meals.enums.meal_type import MealType

"""Tool used for validation in LangGraph"""


class ValidatorTool:
    """We can get rid of it or rethink if we want to adjust in case of failing"""

    def __init__(self, meals_per_day: int, macro_tolerance: int = 1, calorie_tolerance: int = 1):
        self.meals_per_day = meals_per_day
        self.macro_tolerance = macro_tolerance
        self.calorie_tolerance = calorie_tolerance

    def validate_plan(self, state: AgentState) -> Dict[str, Any]:
        plan_meals = self._ensure_complete_meals(state.current_plan)

        errors = []
        suggestions = []

        meals_number_errors, meals_number_suggestions = self._validate_number_and_type_of_meals(
            plan_meals, self.meals_per_day
        )
        errors.extend(meals_number_errors)
        suggestions.extend(meals_number_suggestions)

        actual, target, diffs = self._compute_totals(plan_meals, state.targets)
        macro_errors, macro_suggestions = self._compute_errors_and_suggestions(actual, target, diffs)
        errors.extend(macro_errors)
        suggestions.extend(macro_suggestions)

        if not errors:
            return {"validation_report": "OK"}

        per_meal_targets = self._compute_per_meal_targets(plan_meals, diffs)
        self._adjust_residuals(per_meal_targets, target)

        machine_block = {
            "global": {"actual": actual, "target": target, "diffs": diffs},
            "per_meal_targets": per_meal_targets,
        }

        report_text = self._format_report(errors, suggestions, machine_block)
        return {"validation_report": report_text}

    @staticmethod
    def _ensure_complete_meals(plan_meals: List[CompleteMeal]) -> List[CompleteMeal]:
        return [m if isinstance(m, CompleteMeal) else CompleteMeal(**m) for m in plan_meals]

    @staticmethod
    def _compute_totals(plan_meals: List[CompleteMeal], targets):
        actual = {
            "calories": sum(m.calories for m in plan_meals),
            "protein": sum(m.protein for m in plan_meals),
            "carbs": sum(m.carbs for m in plan_meals),
            "fat": sum(m.fat for m in plan_meals),
        }
        target_vals = {
            "calories": targets.calories,
            "protein": targets.protein,
            "carbs": targets.carbs,
            "fat": targets.fat,
        }
        diffs = {k: target_vals[k] - actual[k] for k in actual}
        return actual, target_vals, diffs

    def _compute_errors_and_suggestions(self, actual, target, diffs):
        errors = []
        suggestions = []
        for macro in ["calories", "protein", "carbs", "fat"]:
            tol = self.calorie_tolerance if macro == "calories" else self.macro_tolerance
            if abs(diffs[macro]) > tol:
                direction = "increase" if diffs[macro] > 0 else "decrease"
                pct = (abs(diffs[macro]) / target[macro] * 100) if target[macro] else 0
                errors.append(f"{macro.capitalize()} mismatch: {actual[macro]} vs target {target[macro]}")
                suggestions.append(f"→ {direction.capitalize()} total {macro} by {abs(diffs[macro]):.1f} ({pct:.1f}%).")
        return errors, suggestions

    def _compute_per_meal_targets(
        self, plan_meals: List[CompleteMeal], diffs: Dict[str, float]
    ) -> List[Dict[str, Any]]:
        n = len(plan_meals)

        def meal_share(current_sum, meal_value):
            return (meal_value / current_sum) if current_sum > 0 else (1.0 / n)

        shares = {macro: [getattr(m, macro) for m in plan_meals] for macro in ["calories", "protein", "carbs", "fat"]}
        per_meal_targets = []

        for i, meal in enumerate(plan_meals):
            mt = {}
            for macro in ["calories", "protein", "carbs", "fat"]:
                current_sum = sum(shares[macro])
                s = meal_share(current_sum, shares[macro][i])
                new_val = getattr(meal, macro) + diffs[macro] * s
                mt[macro] = max(0.0, round(new_val, 1))
            per_meal_targets.append(
                {"meal_index": i, "meal_name": meal.meal_name, "type": meal.meal_type, "targets": mt}
            )
        return per_meal_targets

    @staticmethod
    def _adjust_residuals(per_meal_targets: List[Dict[str, Any]], target: Dict[str, float]):
        for macro in ["calories", "protein", "carbs", "fat"]:
            summed = sum(m["targets"][macro] for m in per_meal_targets)
            residual = round(target[macro] - summed, 1)
            if abs(residual) >= 0.1:
                per_meal_targets[-1]["targets"][macro] = max(
                    0.0, round(per_meal_targets[-1]["targets"][macro] + residual, 1)
                )

    @staticmethod
    def _format_report(errors, suggestions, machine_block):
        return (
            "VALIDATION FAILED:\n"
            + "\n".join(errors)
            + "\n\n"
            + "ACTIONABLE GUIDANCE:\n"
            + "\n".join(suggestions)
            + "\n\n"
            + "PER-MEAL TARGETS (machine-readable JSON follows):\n"
            + json.dumps(machine_block, indent=2)
        )

    @staticmethod
    def _validate_number_and_type_of_meals(plan_meals: List[CompleteMeal], meals_per_day: int):
        errors = []
        suggestions = []
        if len(plan_meals) != meals_per_day:
            errors.append(f"Invalid number of meals: expected {meals_per_day}, got {len(plan_meals)}")
            suggestions.append(f"Try removing or adding meals to get exactly {meals_per_day} meals")
        plan_meal_types = [plan_meal.meal_type for plan_meal in plan_meals]
        if set(plan_meal_types) != set(MealType.daily_meals(meals_per_day)):
            errors.append("Meal types mismatch")
            suggestions.append(
                f"Try changing meals so there is exactly one meal of each of this types:"
                f" {MealType.daily_meals(meals_per_day)}"
            )
        return errors, suggestions
