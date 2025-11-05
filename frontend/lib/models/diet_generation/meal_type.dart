import 'package:flutter/material.dart';

enum MealType {
  breakfast(0, 'breakfast', 'Breakfast', Icons.egg_alt),
  morningSnack(1, 'morning_snack', 'Morning Snack', Icons.free_breakfast),
  lunch(2, 'lunch', 'Lunch', Icons.rice_bowl),
  afternoonSnack(3, 'afternoon_snack', 'Afternoon Snack', Icons.cookie),
  dinner(4, 'dinner', 'Dinner', Icons.dinner_dining),
  eveningSnack(5, 'evening_snack', 'Evening Snack', Icons.bakery_dining);

  final int value;
  final String nameStr;
  final String displayName;
  final IconData icon;

 const MealType(this.value, this.nameStr, this.displayName, this.icon);

  String toJson() => nameStr;

  int toInt() => value;
  IconData toIcon() => icon;

  static MealType fromJson(String value) {
    return MealType.values.firstWhere(
      (e) => e.nameStr == value,
      orElse: () => throw ArgumentError('Unknown meal type: $value'),
    );
  }
}
