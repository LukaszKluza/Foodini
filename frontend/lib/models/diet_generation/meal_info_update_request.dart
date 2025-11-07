import 'package:frontend/models/diet_generation/meal_status.dart';
import 'package:uuid/uuid_value.dart';

class MealInfoUpdateRequest {
  final DateTime day;
  final UuidValue mealId;
  final MealStatus mealStatus;

  MealInfoUpdateRequest({
    required this.day,
    required this.mealId,
    required this.mealStatus,
  });

  Map<String, dynamic> toJson() {
    return {
      'day': day.toIso8601String().split('T').first,
      'meal_id': mealId.uuid,
      'status': mealStatus.toJson(),
    };
  }

  factory MealInfoUpdateRequest.fromJson(Map<String, dynamic> json) {
    return MealInfoUpdateRequest(
      day: DateTime.parse(json['day']),
      mealId: UuidValue.fromString(json['meal_id']),
      mealStatus: MealStatus.fromJson(json['status']),
    );
  }
}