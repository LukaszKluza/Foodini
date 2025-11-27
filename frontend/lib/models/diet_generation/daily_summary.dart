import 'package:frontend/models/diet_generation/meal.dart';
import 'package:frontend/models/diet_generation/meal_info.dart';
import 'package:frontend/models/diet_generation/meal_type.dart';

class DailySummary {
  final DateTime day;
  final Map<MealType, Meal> meals;
  final Map<MealType, MealInfo> generatedMeals;
  final int targetCalories;
  final double targetProtein;
  final double targetCarbs;
  final double targetFat;

  final int eatenCalories;
  final double eatenProtein;
  final double eatenCarbs;
  final double eatenFat;

  final bool isOutDated;

  DailySummary({
    required this.day,
    required this.meals,
    required this.generatedMeals,
    required this.targetCalories,
    required this.targetProtein,
    required this.targetCarbs,
    required this.targetFat,
    required this.eatenCalories,
    required this.eatenProtein,
    required this.eatenCarbs,
    required this.eatenFat,
    required this.isOutDated,
  });

  factory DailySummary.fromJson(Map<String, dynamic> json) {
    final mealsMap = <MealType, Meal>{};
    if (json['meals'] != null) {
      (json['meals'] as Map<String, dynamic>).forEach((key, value) {
        final mealType = MealType.fromJson(key);
        mealsMap[mealType] = Meal.fromJson(value);
      });
    }

    final generatedMealsMap = <MealType, MealInfo>{};
    if (json['generated_meals'] != null) {
      (json['generated_meals'] as Map<String, dynamic>).forEach((key, value) {
        final mealType = MealType.fromJson(key);
        generatedMealsMap[mealType] = MealInfo.fromJson(value);
      });
    }

    return DailySummary(
      day: DateTime.parse(json['day']),
      meals: mealsMap,
      generatedMeals: generatedMealsMap,
      targetCalories: json['target_calories'] as int,
      targetProtein: (json['target_protein'] as num).toDouble(),
      targetCarbs: (json['target_carbs'] as num).toDouble(),
      targetFat: (json['target_fat'] as num).toDouble(),
      eatenCalories: json['eaten_calories'] as int,
      eatenProtein: (json['eaten_protein'] as num).toDouble(),
      eatenCarbs: (json['eaten_carbs'] as num).toDouble(),
      eatenFat: (json['eaten_fat'] as num).toDouble(),
      isOutDated: json['is_out_dated'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    final mealsJson = meals.map((key, value) => MapEntry(
      key.toJson(),
      value.toJson(),
    ));
    final generatedMealsJson = generatedMeals.map((key, value) =>
        MapEntry(key.toJson(), value.toJson()));

    return {
      'day': day.toIso8601String().split('T').first,
      'meals': mealsJson,
      'generated_meals': generatedMealsJson,
      'target_calories': targetCalories,
      'target_protein': targetProtein,
      'target_carbs': targetCarbs,
      'target_fat': targetFat,
      'eaten_calories': eatenCalories,
      'eaten_protein': eatenProtein,
      'eaten_carbs': eatenCarbs,
      'eaten_fat': eatenFat,
      'is_out_dated': isOutDated,
    };
  }
}
