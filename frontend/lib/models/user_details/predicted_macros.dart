class PredictedMacros {
  final int protein;
  final int fat;
  final int carbs;

  PredictedMacros({
    required this.protein,
    required this.fat,
    required this.carbs,
  });

  factory PredictedMacros.fromJson(Map<String, dynamic> json) {
    return PredictedMacros(
      protein: json['protein'],
      fat: json['fat'],
      carbs: json['carbs'],
    );
  }
}
