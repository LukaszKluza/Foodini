import 'package:frontend/models/diet_generation/meal_status.dart';

class MealInfo {
  final int? mealId;
  final MealStatus mealStatus;
  final String? name;
  final int? calories;
  final double? protein;
  final double? carbs;
  final double? fat;

  MealInfo({
    this.mealId,
    required this.mealStatus,
    this.name,
    this.calories,
    this.protein,
    this.carbs,
    this.fat,
  });

  factory MealInfo.fromJson(Map<String, dynamic> json) {
    return MealInfo(
      mealId: json['meal_id'] as int,
      mealStatus: MealStatus.fromJson(json['meal_status']),
      calories: json['calories'] as int,
      protein: (json['protein'] as num).toDouble(),
      carbs: (json['carbs'] as num).toDouble(),
      fat: (json['fat'] as num).toDouble(),
    );
  }
}