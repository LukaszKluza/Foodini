enum Unit {
  // Weight
  kilogram(0, 'kg'),
  gram(1, 'g'),
  milligram(2, 'mg'),

  // Volume
  liter(3, 'l'),
  milliliter(4, 'ml'),
  cup(5, 'cup'),
  tablespoon(6, 'tbsp'),
  teaspoon(7, 'tsp'),

  // Pieces
  piece(8, 'piece'),
  slice(9, 'slice'),
  pack(10, 'pack'),
  can(11, 'can'),
  bottle(12, 'bottle'),

  // Other kitchen measures
  pinch(13, 'pinch'),
  dash(14, 'dash'),
  handful(15, 'handful'),
  stick(16, 'stick');

  final int value;
  final String nameStr;

  const Unit(this.value, this.nameStr);

  String toJson() => nameStr;

  static Unit fromJson(String value) {
    return Unit.values.firstWhere(
          (e) => e.nameStr == value,
      orElse: () => throw ArgumentError('Unknown unit: $value'),
    );
  }

  int toInt() => value;
}