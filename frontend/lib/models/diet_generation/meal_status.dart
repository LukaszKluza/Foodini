enum MealStatus {
  toEat(0, 'to_eat'),
  pending(1, 'pending'),
  eaten(2, 'eaten'),
  skipped(3, 'skipped');

  final int value;
  final String nameStr;

  const MealStatus(this.value, this.nameStr);

  String toJson() => nameStr;

  static MealStatus fromJson(String value) {
    return MealStatus.values.firstWhere(
      (e) => e.nameStr == value,
      orElse: () => throw ArgumentError('Unknown meal status: $value'),
    );
  }

  int toInt() => value;
}
