enum Allergy {
  gluten(0, 'GLUTEN'),
  peanuts(1, 'PEANUTS'),
  lactose(2, 'LACTOSE'),
  fish(3, 'FISH'),
  soy(4, 'SOY'),
  wheat(5, 'WHEAT'),
  celery(6, 'CELERY'),
  sulphites(7, 'SULPHITES'),
  lupin(8, 'LUPIN');

  final int value;
  final String nameStr;

  const Allergy(this.value, this.nameStr);

  String toJson() => nameStr;

  static Allergy fromJson(String value) {
    return Allergy.values.firstWhere(
          (e) => e.nameStr == value.toUpperCase(),
      orElse: () => throw ArgumentError('Unknown allergy: $value'),
    );
  }

  int toInt() => value;

  static Allergy fromInt(int value) {
    return Allergy.values.firstWhere(
          (e) => e.value == value,
      orElse: () => throw ArgumentError('Invalid allergy value: $value'),
    );
  }
}
