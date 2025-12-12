import 'package:frontend/models/diet_generation/meal_type.dart';
import 'package:uuid/uuid_value.dart';

class RemoveMealRequest {
  final DateTime day;
  final MealType mealType;
  final UuidValue mealId;


  RemoveMealRequest({
    required this.day,
    required this.mealType,
    required this.mealId,
  });

  Map<String, dynamic> toJson() {
    return {
      'day': day.toIso8601String().split('T').first,
      'meal_type': mealType.toJson(),
      'meal_id': mealId.uuid,
    };
  }

  factory RemoveMealRequest.fromJson(Map<String, dynamic> json) {
    return RemoveMealRequest(
      day: DateTime.parse(json['day']),
      mealType: MealType.fromJson(json['meal_type']),
      mealId: UuidValue.fromString(json['meal_id']),
    );
  }
}
