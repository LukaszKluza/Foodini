enum MealType {
  breakfast(0, 'breakfast'),
  morningSnack(1, 'morning_snack'),
  lunch(2, 'lunch'),
  afternoonSnack(3, 'afternoon_snack'),
  dinner(4, 'dinner'),
  eveningSnac(5, 'evening_snack');

  final int value;
  final String nameStr;

  const MealType(this.value, this.nameStr);

  String toJson() => nameStr;

  static MealType fromJson(String value) {
    return MealType.values.firstWhere(
      (e) => e.nameStr == value,
      orElse: () => throw ArgumentError('Unknown diet type: $value'),
    );
  }

  int toInt() => value;
}
