enum SleepQuality {
  poor(0, 'POOR'),
  fair(1, 'FAIR'),
  good(2, 'GOOD'),
  excellent(3, 'EXCELLENT');

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
