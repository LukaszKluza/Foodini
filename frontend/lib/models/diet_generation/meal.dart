import 'package:frontend/models/diet_generation/meal_info.dart';
import 'package:frontend/models/diet_generation/meal_status.dart';

class Meal {
  final List<MealInfo> _mealItems;
  final MealStatus status;

  Meal({
    required List<MealInfo> mealItems,
    required this.status,
  }) : _mealItems = mealItems;

  List<MealInfo> get mealItems {
    final sorted = List<MealInfo>.from(_mealItems);
    sorted.sort((a, b) => a.name.compareTo(b.name));
    return sorted;
  }

  Map<String, dynamic> toJson() => {
    'meal_items': _mealItems.map((item) => item.toJson()).toList(),
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