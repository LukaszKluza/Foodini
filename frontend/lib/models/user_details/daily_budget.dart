enum DailyBudget {
  low(0, 'low'),
  medium(1, 'medium'),
  high(2, 'high');

  final int value;
  final String nameStr;

  const DailyBudget(this.value, this.nameStr);

  String toJson() => nameStr;

  static DailyBudget fromJson(String value) {
    return DailyBudget.values.firstWhere(
          (e) => e.nameStr == value,
      orElse: () => throw ArgumentError('Unknown budget: $value'),
    );
  }

  int toInt() => value;

  static DailyBudget fromInt(int value) {
    return DailyBudget.values.firstWhere(
          (e) => e.value == value,
      orElse: () => throw ArgumentError('Invalid budget value: $value'),
    );
  }
}
