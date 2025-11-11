enum DietaryRestriction {
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

  const DietaryRestriction(this.value, this.nameStr);

  String toJson() => nameStr;

  static DietaryRestriction fromJson(String value) {
    return DietaryRestriction.values.firstWhere(
      (e) => e.nameStr == value,
      orElse: () => throw ArgumentError('Unknown dietary restriction: $value'),
    );
  }

  int toInt() => value;

  static DietaryRestriction fromInt(int value) {
    return DietaryRestriction.values.firstWhere(
      (e) => e.value == value,
      orElse: () => throw ArgumentError('Invalid dietary restriction value: $value'),
    );
  }
}
