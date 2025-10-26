import 'package:frontend/models/diet_generation/meal_status.dart';

class MealInfo {
  final int? mealId;
  final MealStatus mealStatus;
  final String? customName;
  final double? customCalories;
  final double? customProtein;
  final double? customCarbs;
  final double? customFat;

  MealInfo({
    this.mealId,
    required this.mealStatus,
    this.customName,
    this.customCalories,
    this.customProtein,
    this.customCarbs,
    this.customFat,
  });

  Map<String, dynamic> toJson() {
    return {
      'meal_id': mealId,
      'meal_status': mealStatus.toJson(),
    };
  }

  factory MealInfo.fromJson(Map<String, dynamic> json) {
    return MealInfo(
      mealId: json['meal_id'] as int,
      mealStatus: MealStatus.fromJson(json['meal_status']),
      customCalories: (json['custom_calories'] as num).toDouble(),
      customProtein: (json['custom_protein'] as num).toDouble(),
      customCarbs: (json['custom_carbs'] as num).toDouble(),
      customFat: (json['custom_fat'] as num).toDouble(),
    );
  }
}