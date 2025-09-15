enum Allergy {
  gluten(0, 'gluten'),
  peanuts(1, 'peanuts'),
  lactose(2, 'lactose'),
  fish(3, 'fish'),
  soy(4, 'soy'),
  wheat(5, 'wheat'),
  celery(6, 'celery'),
  sulphites(7, 'sulphites'),
  lupin(8, 'lupin');

  final int value;
  final String nameStr;

  const Allergy(this.value, this.nameStr);

  String toJson() => nameStr;

  static Allergy fromJson(String value) {
    return Allergy.values.firstWhere(
      (e) => e.nameStr == value,
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
