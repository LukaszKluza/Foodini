class Macros {
  final double protein;
  final double fat;
  final double carbs;

  Macros({
    required this.protein,
    required this.fat,
    required this.carbs,
  });

  factory Macros.fromJson(Map<String, dynamic> json) {
    return Macros(
      protein: json['protein'],
      fat: json['fat'],
      carbs: json['carbs'],
    );
  }

  Map<String, dynamic> toJson() => {
    'protein': protein,
    'fat': fat,
    'carbs': carbs,
  };
}
