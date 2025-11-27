import 'package:frontend/models/diet_generation/meal_type.dart';
import 'package:uuid/uuid_value.dart';

class CustomMealUpdateRequest {
  final DateTime day;
  final MealType mealType;
  final UuidValue? mealId;
  final String? customName;
  final int customCalories;
  final double customProtein;
  final double customCarbs;
  final double customFat;
  final int? eatenWeight;

  CustomMealUpdateRequest({
    required this.day,
    required this.mealType,
    this.mealId,
    this.customName,
    required this.customCalories,
    required this.customProtein,
    required this.customCarbs,
    required this.customFat,
    required this.eatenWeight,
  });

  Map<String, dynamic> toJson() {
    return {
      'day': day.toIso8601String().split('T').first,
      'meal_type': mealType.toJson(),
      'meal_id': mealId?.uuid,
      'custom_name': customName,
      'custom_calories': customCalories,
      'custom_protein': customProtein,
      'custom_carbs': customCarbs,
      'custom_fat': customFat,
      'custom_weight': eatenWeight,
    };
  }

  factory CustomMealUpdateRequest.fromJson(Map<String, dynamic> json) {
    return CustomMealUpdateRequest(
      day: DateTime.parse(json['day']),
      mealType: MealType.fromJson(json['meal_type']),
      mealId: UuidValue.fromString(json['meal_id']),
      customName: json['custom_name'],
      customCalories: json['custom_calories'] as int,
      customProtein: (json['custom_protein'] as num).toDouble(),
      customCarbs: (json['custom_carbs'] as num).toDouble(),
      customFat: (json['custom_fat'] as num).toDouble(),
      eatenWeight: json['custom_weight'] as int,
    );
  }
}
