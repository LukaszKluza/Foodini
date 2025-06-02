enum SleepQuality {
  poor(0, 'poor'),
  fair(1, 'fair'),
  good(2, 'good'),
  excellent(3, 'excellent');

  final int value;
  final String nameStr;

  const SleepQuality(this.value, this.nameStr);

  String toJson() => nameStr;

  static SleepQuality fromJson(String value) {
    return SleepQuality.values.firstWhere(
      (e) => e.nameStr == value.toUpperCase(),
      orElse: () => throw ArgumentError('Unknown sleep quality: $value'),
    );
  }

  int toInt() => value;

  static SleepQuality fromInt(int value) {
    return SleepQuality.values.firstWhere(
      (e) => e.value == value,
      orElse: () => throw ArgumentError('Invalid sleep quality value: $value'),
    );
  }
}
