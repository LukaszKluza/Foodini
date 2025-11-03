import 'package:frontend/models/diet_generation/meal_info.dart';
import 'package:frontend/models/diet_generation/meal_type.dart';

class DailySummary {
  final DateTime day;
  final Map<MealType, MealInfo> meals;
  final int targetCalories;
  final double targetProtein;
  final double targetCarbs;
  final double targetFat;

  final int currentCalories;
  final double currentProtein;
  final double currentCarbs;
  final double currentFat;

  DailySummary({
    required this.day,
    required this.meals,
    required this.targetCalories,
    required this.targetProtein,
    required this.targetCarbs,
    required this.targetFat,
    required this.currentCalories,
    required this.currentProtein,
    required this.currentCarbs,
    required this.currentFat,
  });

  factory DailySummary.fromJson(Map<String, dynamic> json) {
    final mealsMap = <MealType, MealInfo>{};
    if (json['meals'] != null) {
      (json['meals'] as Map<String, dynamic>).forEach((key, value) {
        final mealType = MealType.fromJson(key);
        mealsMap[mealType] = MealInfo.fromJson(value);
      });
    }

    return DailySummary(
      day: DateTime.parse(json['day']),
      meals: mealsMap,
      targetCalories: json['target_calories'] as int,
      targetProtein: (json['target_protein'] as num).toDouble(),
      targetCarbs: (json['target_carbs'] as num).toDouble(),
      targetFat: (json['target_fat'] as num).toDouble(),
      currentCalories: json['current_calories'] as int,
      currentProtein: (json['current_protein'] as num).toDouble(),
      currentCarbs: (json['current_carbs'] as num).toDouble(),
      currentFat: (json['current_fat'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    final mealsJson = meals.map((key, value) => MapEntry(key.toJson(), value.toJson()));

    return {
      'day': day.toIso8601String().split('T').first,
      'meals': mealsJson,
      'target_calories': targetCalories,
      'target_protein': targetProtein,
      'target_carbs': targetCarbs,
      'target_fat': targetFat,
      'current_calories': currentCalories,
      'current_protein': currentProtein,
      'current_carbs': currentCarbs,
      'current_fat': currentFat,
    };
  }
}
