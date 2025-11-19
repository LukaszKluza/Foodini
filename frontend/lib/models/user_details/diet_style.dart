enum DietStyle {
  vegetarian(0, 'vegetarian'),
  vegan(1, 'vegan'),
  keto(2, 'keto');

  final int value;
  final String nameStr;

  const DietStyle(this.value, this.nameStr);

  String toJson() => nameStr;

  static DietStyle fromJson(String value) {
    return DietStyle.values.firstWhere(
      (e) => e.nameStr == value,
      orElse: () => throw ArgumentError('Unknown diet style: $value'),
    );
  }

  int toInt() => value;

  static DietStyle fromInt(int value) {
    return DietStyle.values.firstWhere(
      (e) => e.value == value,
      orElse: () => throw ArgumentError('Invalid diet style: $value'),
    );
  }
}
