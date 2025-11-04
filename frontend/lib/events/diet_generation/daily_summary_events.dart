import 'package:frontend/models/diet_generation/meal_info.dart';
import 'package:frontend/models/diet_generation/meal_status.dart';
import 'package:frontend/models/diet_generation/meal_type.dart';
import 'package:uuid/uuid_value.dart';

abstract class DailySummaryEvent {}

class GetDailySummary extends DailySummaryEvent {
  final DateTime day;

  GetDailySummary(this.day);
}

class UpdateMeal extends DailySummaryEvent {
  final MealType mealType;
  final MealInfo updatedMeal;

  UpdateMeal({
    required this.mealType,
    required this.updatedMeal,
  });
}

class ChangeMealStatus extends DailySummaryEvent {
  final DateTime day;
  final UuidValue mealId;
  final MealStatus status;

  ChangeMealStatus({
    required this.day,
    required this.mealId,
    required this.status,
  });
}

class ResetDailySummary extends DailySummaryEvent {}
