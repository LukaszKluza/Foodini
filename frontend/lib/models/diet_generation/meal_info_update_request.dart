import 'package:frontend/models/diet_generation/meal_status.dart';
import 'package:frontend/models/diet_generation/meal_type.dart';

class MealInfoUpdateRequest {
  final DateTime day;
  final MealType mealType;
  final MealStatus mealStatus;

  MealInfoUpdateRequest({
    required this.day,
    required this.mealType,
    required this.mealStatus,
  });

  Map<String, dynamic> toJson() {
    return {
      'day': day.toIso8601String().split('T').first,
      'meal_type': mealType.toJson(),
      'meal_status': mealStatus.toJson(),
    };
  }

  factory MealInfoUpdateRequest.fromJson(Map<String, dynamic> json) {
    return MealInfoUpdateRequest(
      day: DateTime.parse(json['day']),
      mealType: MealType.fromJson(json['meal_type']),
      mealStatus: MealStatus.fromJson(json['meal_status']),
    );
  }
}