enum DietIntensity {
  slow(0, 'slow'),
  medium(1, 'normal'),
  fast(2, 'fast');

  final int value;
  final String nameStr;

  const DietIntensity(this.value, this.nameStr);

  String toJson() => nameStr;

  static DietIntensity fromJson(String value) {
    return DietIntensity.values.firstWhere(
          (e) => e.nameStr == value.toUpperCase(),
      orElse: () => throw ArgumentError('Unknown diet intensity: $value'),
    );
  }

  int toInt() => value;

  static DietIntensity fromInt(int value) {
    return DietIntensity.values.firstWhere(
          (e) => e.value == value,
      orElse: () => throw ArgumentError('Invalid diet intensity value: $value'),
    );
  }
}
