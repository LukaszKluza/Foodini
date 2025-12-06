import 'package:frontend/models/diet_generation/meal_info.dart';

class MacrosSummary {
  final double carbs;
  final double fat;
  final double protein;
  final int calories;

  MacrosSummary({
    required this.carbs,
    required this.fat,
    required this.protein,
    required this.calories,
  });

  MacrosSummary.zero()
      : carbs = 0,
        fat = 0,
        protein = 0,
        calories = 0;

  static MacrosSummary calculateTotalMacros(List<MealInfo> meals) {
    double totalProtein = 0;
    double totalCarbs = 0;
    double totalFat = 0;
    int totalCalories = 0;

    for (final meal in meals) {
      totalProtein += meal.plannedProtein;
      totalCarbs += meal.plannedCarbs;
      totalFat += meal.plannedFat;
      totalCalories += meal.plannedCalories;
    }

    return MacrosSummary(
      carbs: double.parse(totalCarbs.toStringAsFixed(2)),
      fat: double.parse(totalFat.toStringAsFixed(2)),
      protein: double.parse(totalProtein.toStringAsFixed(2)),
      calories: totalCalories,
    );
  }

  Map<String, dynamic> toJson() => {
    'carbs': carbs,
    'fat': fat,
    'protein': protein,
    'calories': calories,
  };

  factory MacrosSummary.fromJson(Map<String, dynamic> json) {
    return MacrosSummary(
      carbs: (json['carbs'] as num).toDouble(),
      fat: (json['fat'] as num).toDouble(),
      protein: (json['protein'] as num).toDouble(),
      calories: json['calories'] as int,
    );
  }
}
