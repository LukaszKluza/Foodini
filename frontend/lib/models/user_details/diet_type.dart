enum DietType {
  fatLoss(0, 'FAT_LOSS'),
  muscleGain(1, 'MUSCLE_GAIN'),
  weightMaintenance(2, 'WEIGHT_MAINTENANCE'),
  vegetarian(3, 'VEGETARIAN'),
  vegan(4, 'VEGAN'),
  keto(5, 'KETO');

  final int value;
  final String nameStr;

  const DietType(this.value, this.nameStr);

  String toJson() => nameStr;

  static DietType fromJson(String value) {
    return DietType.values.firstWhere(
          (e) => e.nameStr == value.toUpperCase(),
      orElse: () => throw ArgumentError('Unknown diet type: $value'),
    );
  }

  int toInt() => value;

  static DietType fromInt(int value) {
    return DietType.values.firstWhere(
          (e) => e.value == value,
      orElse: () => throw ArgumentError('Invalid diet type value: $value'),
    );
  }
}
