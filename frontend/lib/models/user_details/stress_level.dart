enum StressLevel {
  low(0, 'LOW'),
  medium(1, 'MEDIUM'),
  high(2, 'HIGH'),
  extreme(3, 'EXTREME');

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
