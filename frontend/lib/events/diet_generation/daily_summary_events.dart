import 'package:frontend/models/diet_generation/custom_meal_update_request.dart';
import 'package:frontend/models/diet_generation/meal_status.dart';
import 'package:frontend/models/diet_generation/meal_type.dart';
import 'package:image_picker/image_picker.dart';

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
  final MealType mealType;
  final MealStatus status;

  ChangeMealStatus({
    required this.day,
    required this.mealType,
    required this.status,
  });
}

class GenerateMealPlan extends DailySummaryEvent {
  final DateTime day;

  GenerateMealPlan({
    required this.day
  });
}

class AddScannedProduct extends DailySummaryEvent {
  final String? barcode;
  final XFile? uploadedFile;
  final MealType mealType;

  AddScannedProduct({
    this.barcode,
    this.uploadedFile,
    required this.mealType
  });
}

class ResetDailySummary extends DailySummaryEvent {}
