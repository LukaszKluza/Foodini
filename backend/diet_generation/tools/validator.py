import json
from typing import Dict, Any

from backend.diet_generation.schemas import AgentState, CompleteMeal

"""Tool used for validation in LangGraph"""
class ValidatorTool:

    """We can get rid of it or rethink if we want to adjust in case of failing"""
    def __init__(self, macro_tolerance: int = 1, calorie_tolerance: int = 1):
        self.macro_tolerance = macro_tolerance
        self.calorie_tolerance = calorie_tolerance

    def validate_plan(self, state: AgentState) -> Dict[str, Any]:
        plan_meals = state.current_plan
        targets = state.targets

        if not all(isinstance(meal, CompleteMeal) for meal in plan_meals):
            plan_meals = [CompleteMeal(**meal) for meal in plan_meals]

        actual = {
            "calories": sum(m.calories for m in plan_meals),
            "protein": sum(m.protein for m in plan_meals),
            "carbs": sum(m.carbs for m in plan_meals),
            "fat": sum(m.fat for m in plan_meals),
        }
        target = {
            "calories": targets.calories,
            "protein": targets.protein,
            "carbs": targets.carbs,
            "fat": targets.fat,
        }

        diffs = {k: target[k] - actual[k] for k in actual}

        errors = []
        suggestions = []
        for macro in ["calories", "protein", "carbs", "fat"]:
            tol = self.calorie_tolerance if macro == "calories" else self.macro_tolerance
            if abs(diffs[macro]) > tol:
                direction = "increase" if diffs[macro] > 0 else "decrease"
                pct = (abs(diffs[macro]) / target[macro] * 100) if target[macro] else 0
                errors.append(f"{macro.capitalize()} mismatch: {actual[macro]} vs target {target[macro]}")
                suggestions.append(f"→ {direction.capitalize()} total {macro} by {abs(diffs[macro]):.1f} ({pct:.1f}%).")

        if not errors:
            return {"validation_report": "OK"}

        n = len(plan_meals)
        def meal_share(current_sum, meal_value):
            return (meal_value / current_sum) if current_sum > 0 else (1.0 / n)

        shares = {
            "calories": [m.calories for m in plan_meals],
            "protein": [m.protein for m in plan_meals],
            "carbs": [m.carbs for m in plan_meals],
            "fat": [m.fat for m in plan_meals],
        }

        per_meal_targets = []
        for i, meal in enumerate(plan_meals):
            mt = {}
            for macro in ["calories", "protein", "carbs", "fat"]:
                current_sum = sum(shares[macro])
                s = meal_share(current_sum, shares[macro][i])
                new_val = getattr(meal, macro) + diffs[macro] * s
                new_val = round(new_val, 1)
                mt[macro] = max(0.0, new_val)
            per_meal_targets.append({
                "meal_index": i,
                "meal_name": meal.meal_name,
                "type": meal.meal_type,
                "targets": mt
            })

        for macro in ["calories", "protein", "carbs", "fat"]:
            summed = sum(m["targets"][macro] for m in per_meal_targets)
            residual = round(target[macro] - summed, 1)
            if abs(residual) >= 0.1:  # if small, add to last meal
                per_meal_targets[-1]["targets"][macro] = max(
                    0.0,
                    round(per_meal_targets[-1]["targets"][macro] + residual, 1)
                )

        machine_block = {
            "global": {"actual": actual, "target": target, "diffs": diffs},
            "per_meal_targets": per_meal_targets
        }

        report_text = (
            "VALIDATION FAILED:\n"
            + "\n".join(errors) + "\n\n"
            + "ACTIONABLE GUIDANCE:\n"
            + "\n".join(suggestions) + "\n\n"
            + "PER-MEAL TARGETS (machine-readable JSON follows):\n"
            + json.dumps(machine_block, indent=2)
        )

        return {"validation_report": report_text}