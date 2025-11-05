import 'package:frontend/models/diet_generation/meal_info.dart';
import 'package:frontend/models/diet_generation/meal_type.dart';

class DailyMealsCreate {
  final DateTime day;
  final Map<MealType, MealInfo> meals;
  final int targetCalories;
  final double targetProtein;
  final double targetCarbs;
  final double targetFat;

  DailyMealsCreate({
    required this.day,
    required this.meals,
    required this.targetCalories,
    required this.targetProtein,
    required this.targetCarbs,
    required this.targetFat,
  });

  factory DailyMealsCreate.fromJson(Map<String, dynamic> json) {
    final mealsMap = <MealType, MealInfo>{};
    if (json['meals'] != null) {
      (json['meals'] as Map<String, dynamic>).forEach((key, value) {
        final mealType = MealType.fromJson(key);
        mealsMap[mealType] = MealInfo.fromJson(value);
      });
    }

    return DailyMealsCreate(
      day: DateTime.parse(json['day']),
      meals: mealsMap,
      targetCalories: json['target_calories'] as int,
      targetProtein: (json['target_protein'] as num).toDouble(),
      targetCarbs: (json['target_carbs'] as num).toDouble(),
      targetFat: (json['target_fat'] as num).toDouble(),
    );
  }
}