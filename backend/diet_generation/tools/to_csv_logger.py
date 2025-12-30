import os
import csv
from functools import wraps
from datetime import datetime


def log_diet_stats(func):
    @wraps(func)
    def wrapper(self, state, *args, **kwargs):
        result = func(self, state, *args, **kwargs)

        report_text = result.get("validation_report", "N/A")

        plan_meals = self._ensure_complete_meals(state.current_plan)
        targets = state.targets

        file_name = 'diet_generation_stats.csv'
        file_exists = os.path.isfile(file_name)

        with open(file_name, mode='a', newline='', encoding='utf-8') as f:
            writer = csv.writer(f)

            if not file_exists:
                writer.writerow([
                    'timestamp', 'diet_style', 'expected_kcal', 'actual_kcal',
                    'expected_protein', 'actual_protein', 'expected_carbs', 'actual_carbs',
                    'expected_fat', 'actual_fat', 'meals_count', 'validation_report'
                ])

            actual_kcal = sum(m.calories for m in plan_meals)
            actual_protein = sum(m.protein for m in plan_meals)
            actual_carbs = sum(m.carbs for m in plan_meals)
            actual_fat = sum(m.fat for m in plan_meals)

            clean_report = str(report_text).replace('\n', ' | ')

            writer.writerow([
                datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
                targets.diet_style if targets else "N/A",
                targets.calories if targets else 0, actual_kcal,
                targets.protein if targets else 0, actual_protein,
                targets.carbs if targets else 0, actual_carbs,
                targets.fat if targets else 0, actual_fat,
                len(plan_meals),
                clean_report
            ])

        return result

    return wrapper