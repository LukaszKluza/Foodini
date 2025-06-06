enum StressLevel {
  low(0, 'low'),
  medium(1, 'medium'),
  high(2, 'high'),
  extreme(3, 'extreme');

  final int value;
  final String nameStr;

  const StressLevel(this.value, this.nameStr);

  String toJson() => nameStr;

  static StressLevel fromJson(String value) {
    return StressLevel.values.firstWhere(
      (e) => e.nameStr == value.toUpperCase(),
      orElse: () => throw ArgumentError('Unknown stress level: $value'),
    );
  }

  int toInt() => value;

  static StressLevel fromInt(int value) {
    return StressLevel.values.firstWhere(
      (e) => e.value == value,
      orElse: () => throw ArgumentError('Invalid stress level value: $value'),
    );
  }
}
