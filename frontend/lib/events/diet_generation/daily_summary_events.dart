import 'package:frontend/models/diet_generation/custom_meal_update_request.dart';
import 'package:frontend/models/diet_generation/meal_status.dart';
import 'package:uuid/uuid_value.dart';

abstract class DailySummaryEvent {}

class GetDailySummary extends DailySummaryEvent {
  final DateTime day;

  GetDailySummary(this.day);
}

class UpdateMeal extends DailySummaryEvent {
  final CustomMealUpdateRequest customMealUpdateRequest;

  UpdateMeal({
    required this.customMealUpdateRequest,
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
