class MealTypeMacrosSummary {
  final double carbs;
  final double fat;
  final double protein;
  final int calories;

  MealTypeMacrosSummary({
    required this.carbs,
    required this.fat,
    required this.protein,
    required this.calories,
  });

  MealTypeMacrosSummary.zero()
      : carbs = 0,
        fat = 0,
        protein = 0,
        calories = 0;

  Map<String, dynamic> toJson() => {
    'carbs': carbs,
    'fat': fat,
    'protein': protein,
    'calories': calories,
  };

  factory MealTypeMacrosSummary.fromJson(Map<String, dynamic> json) {
    return MealTypeMacrosSummary(
      carbs: (json['carbs'] as num).toDouble(),
      fat: (json['fat'] as num).toDouble(),
      protein: (json['protein'] as num).toDouble(),
      calories: json['calories'] as int,
    );
  }
}
