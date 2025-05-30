enum ActivityLevel {
  veryLow(0, 'VERY_LOW'),
  light(1, 'LIGHT'),
  moderate(2, 'MODERATE'),
  active(3, 'ACTIVE'),
  veryActive(4, 'VERY_ACTIVE');

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
