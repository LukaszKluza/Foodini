import 'package:frontend/models/diet_generation/meal_type.dart';
import 'package:uuid/uuid_value.dart';

class RemoveMealResponse {
  final DateTime day;
  final MealType mealType;
  final UuidValue mealId;
  bool success;


  RemoveMealResponse({
    required this.day,
    required this.mealType,
    required this.mealId,
    required this.success,
  });

  Map<String, dynamic> toJson() {
    return {
      'day': day.toIso8601String().split('T').first,
      'meal_type': mealType.toJson(),
      'meal_id': mealId.uuid,
      'success': success,
    };
  }

  factory RemoveMealResponse.fromJson(Map<String, dynamic> json) {
    return RemoveMealResponse(
      day: DateTime.parse(json['day']),
      mealType: MealType.fromJson(json['meal_type']),
      mealId: UuidValue.fromString(json['meal_id']),
      success: json['success']
    );
  }
}
