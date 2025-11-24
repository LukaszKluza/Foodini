import 'package:frontend/models/diet_generation/meal_info.dart';
import 'package:frontend/models/diet_generation/meal_type.dart';

class DailySummary {
  final DateTime day;
  final Map<MealType, List<MealInfo>> meals;
  final int targetCalories;
  final double targetProtein;
  final double targetCarbs;
  final double targetFat;

  final int eatenCalories;
  final double eatenProtein;
  final double eatenCarbs;
  final double eatenFat;

  DailySummary({
    required this.day,
    required this.meals,
    required this.targetCalories,
    required this.targetProtein,
    required this.targetCarbs,
    required this.targetFat,
    required this.eatenCalories,
    required this.eatenProtein,
    required this.eatenCarbs,
    required this.eatenFat,
  });

  factory DailySummary.fromJson(Map<String, dynamic> json) {
    final mealsMap = <MealType, List<MealInfo>>{};
    if (json['meals'] != null) {
      (json['meals'] as Map<String, dynamic>).forEach((key, value) {
        final mealType = MealType.fromJson(key);
        final mealList = (value as List)
          .map((mealJson) => MealInfo.fromJson(mealJson))
          .toList();
        mealsMap[mealType] = mealList;
      });
    }

    return DailySummary(
      day: DateTime.parse(json['day']),
      meals: mealsMap,
      targetCalories: json['target_calories'] as int,
      targetProtein: (json['target_protein'] as num).toDouble(),
      targetCarbs: (json['target_carbs'] as num).toDouble(),
      targetFat: (json['target_fat'] as num).toDouble(),
      eatenCalories: json['eaten_calories'] as int,
      eatenProtein: (json['eaten_protein'] as num).toDouble(),
      eatenCarbs: (json['eaten_carbs'] as num).toDouble(),
      eatenFat: (json['eaten_fat'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    final mealsJson = meals.map((key, value) => MapEntry(
      key.toJson(),
      value.map((meal) => meal.toJson()).toList(),
    ));

    return {
      'day': day.toIso8601String().split('T').first,
      'meals': mealsJson,
      'target_calories': targetCalories,
      'target_protein': targetProtein,
      'target_carbs': targetCarbs,
      'target_fat': targetFat,
      'eaten_calories': eatenCalories,
      'eaten_protein': eatenProtein,
      'eaten_carbs': eatenCarbs,
      'eaten_fat': eatenFat,
    };
  }
}
