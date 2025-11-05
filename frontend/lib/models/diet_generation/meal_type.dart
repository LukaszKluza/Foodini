enum MealType {
  breakfast(0, 'breakfast', 'Breakfast'),
  morningSnack(1, 'morning_snack', 'Morning Snack'),
  lunch(2, 'lunch', 'Lunch'),
  afternoonSnack(3, 'afternoon_snack', 'Afternoon Snack'),
  dinner(4, 'dinner', 'Dinner'),
  eveningSnack(5, 'evening_snack', 'Evening Snack');

  final int value;
  final String nameStr;
  final String displayName;

  const MealType(this.value, this.nameStr, this.displayName);

  String toJson() => nameStr;

  static MealType fromJson(String value) {
    return MealType.values.firstWhere(
      (e) => e.nameStr == value,
      orElse: () => throw ArgumentError('Unknown meal type: $value'),
    );
  }

  int toInt() => value;
}
