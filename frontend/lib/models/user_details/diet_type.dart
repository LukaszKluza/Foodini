enum DietType {
  fatLoss(0, 'fat_loss'),
  muscleGain(1, 'muscle_gain'),
  weightMaintenance(2, 'weight_maintenance'),
  vegetarian(3, 'vegetarian'),
  vegan(4, 'vegan'),
  keto(5, 'keto');

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
