enum ActivityLevel {
  veryLow(0, 'very_low'),
  light(1, 'light'),
  moderate(2, 'moderate'),
  active(3, 'active'),
  veryActive(4, 'very_active');

  final int value;
  final String nameStr;

  const ActivityLevel(this.value, this.nameStr);

  String toJson() => nameStr;

  static ActivityLevel fromJson(String value) {
    return ActivityLevel.values.firstWhere(
      (e) => e.nameStr == value.toUpperCase(),
      orElse: () => throw ArgumentError('Unknown activity level: $value'),
    );
  }

  int toInt() => value;

  static ActivityLevel fromInt(int value) {
    return ActivityLevel.values.firstWhere(
      (e) => e.value == value,
      orElse: () => throw ArgumentError('Invalid activity level value: $value'),
    );
  }
}
