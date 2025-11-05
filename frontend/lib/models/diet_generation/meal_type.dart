import 'package:flutter/material.dart';

enum MealType {
  breakfast(0, 'breakfast', Icons.egg_alt),
  morningSnack(1, 'morning_snack', Icons.free_breakfast),
  lunch(2, 'lunch', Icons.rice_bowl),
  afternoonSnack(3, 'afternoon_snack', Icons.cookie),
  dinner(4, 'dinner', Icons.dinner_dining),
  eveningSnack(5, 'evening_snack', Icons.bakery_dining);

  final int value;
  final String nameStr;
  final IconData icon;

 const MealType(this.value, this.nameStr, this.icon);

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
