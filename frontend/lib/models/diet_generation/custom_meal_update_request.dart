import 'package:frontend/models/diet_generation/meal_status.dart';
import 'package:frontend/models/diet_generation/meal_type.dart';

class CustomMealUpdateRequest {
  final DateTime day;
  final MealType mealType;
  final String customName;
  final double customCalories;
  final double customProtein;
  final double customCarbs;
  final double customFat;
  final MealStatus mealStatus;

  CustomMealUpdateRequest({
    required this.day,
    required this.mealType,
    required this.customName,
    required this.customCalories,
    required this.customProtein,
    required this.customCarbs,
    required this.customFat,
    required this.mealStatus,
  });

  Map<String, dynamic> toJson() {
    return {
      'day': day.toIso8601String().split('T').first,
      'meal_type': mealType.toJson(),
      'custom_name': customName,
      'custom_calories': customCalories,
      'custom_protein': customProtein,
      'custom_carbs': customCarbs,
      'custom_fat': customFat,
      'meal_status': mealStatus.toJson(),
    };
  }

  factory CustomMealUpdateRequest.fromJson(Map<String, dynamic> json) {
    return CustomMealUpdateRequest(
      day: DateTime.parse(json['day']),
      mealType: MealType.fromJson(json['meal_type']),
      customName: json['custom_name'],
      customCalories: (json['custom_calories'] as num).toDouble(),
      customProtein: (json['custom_protein'] as num).toDouble(),
      customCarbs: (json['custom_carbs'] as num).toDouble(),
      customFat: (json['custom_fat'] as num).toDouble(),
      mealStatus: MealStatus.fromJson(json['meal_status']),
    );
  }
}
