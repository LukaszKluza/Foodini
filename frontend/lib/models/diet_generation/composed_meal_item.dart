import 'package:uuid/uuid_value.dart';

class ComposedMealItem {
  final UuidValue mealDailySummaryId;
  final UuidValue mealId;
  final int plannedCalories;
  final int plannedWeight;
  final double plannedProtein;
  final double plannedCarbs;
  final double plannedFat;

  ComposedMealItem({
    required this.mealDailySummaryId,
    required this.mealId,
    required this.plannedCalories,
    required this.plannedWeight,
    required this.plannedProtein,
    required this.plannedCarbs,
    required this.plannedFat,
  });

  factory ComposedMealItem.fromJson(Map<String, dynamic> json) {
    return ComposedMealItem(
      mealDailySummaryId: UuidValue.fromString(json['meal_daily_summary_id']),
      mealId: UuidValue.fromString(json['meal_id']),
      plannedCalories: json['planned_calories'] as int,
      plannedWeight: json['planned_weight'] as int,
      plannedProtein: (json['planned_protein'] as num).toDouble(),
      plannedCarbs: (json['planned_carbs'] as num).toDouble(),
      plannedFat: (json['planned_fat'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'meal_daily_summary_id': mealDailySummaryId.toString(),
      'meal_id': mealId.toString(),
      'planned_calories': plannedCalories,
      'planned_weight': plannedWeight,
      'planned_protein': plannedProtein,
      'planned_carbs': plannedCarbs,
      'planned_fat': plannedFat,
    };
  }
}