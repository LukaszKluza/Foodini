import 'package:frontend/models/diet_generation/meal_info.dart';
import 'package:frontend/models/diet_generation/meal_status.dart';

class Meal {
  final List<MealInfo> mealItems;
  final MealStatus status;

  Meal({
    required this.mealItems,
    required this.status,
  });

  Map<String, dynamic> toJson() => {
    'meal_items': mealItems.map((item) => item.toJson()).toList(),
    'status': status.toJson(),
  };

  factory Meal.fromJson(Map<String, dynamic> json) {
    final mealList = (json['meal_items'] as List)
        .map((mealJson) => MealInfo.fromJson(mealJson))
        .toList();

    return Meal(
      mealItems: mealList,
      status: MealStatus.fromJson(json['status']),
    );
  }
}