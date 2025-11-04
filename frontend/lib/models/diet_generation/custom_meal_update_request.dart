import 'package:uuid/uuid_value.dart';

class CustomMealUpdateRequest {
  final DateTime day;
  final UuidValue mealId;
  final String? customName;
  final int? customCalories;
  final double? customProtein;
  final double? customCarbs;
  final double? customFat;

  CustomMealUpdateRequest({
    required this.day,
    required this.mealId,
    this.customName,
    required this.customCalories,
    required this.customProtein,
    required this.customCarbs,
    required this.customFat,
  });

  Map<String, dynamic> toJson() {
    return {
      'day': day.toIso8601String().split('T').first,
      'meal_id': mealId.uuid,
      'custom_name': customName,
      'custom_calories': customCalories,
      'custom_protein': customProtein,
      'custom_carbs': customCarbs,
      'custom_fat': customFat,
    };
  }

  factory CustomMealUpdateRequest.fromJson(Map<String, dynamic> json) {
    return CustomMealUpdateRequest(
      day: DateTime.parse(json['day']),
      mealId: UuidValue.fromString(json['meal_id']),
      customName: json['custom_name'],
      customCalories: json['custom_calories'] as int,
      customProtein: (json['custom_protein'] as num).toDouble(),
      customCarbs: (json['custom_carbs'] as num).toDouble(),
      customFat: (json['custom_fat'] as num).toDouble(),
    );
  }
}
