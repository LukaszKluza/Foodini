class DailyMacrosSummaryCreate {
  final DateTime day;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;

  DailyMacrosSummaryCreate({
    required this.day,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });

  Map<String, dynamic> toJson() {
    return {
      'day': day.toIso8601String().split('T').first,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
    };
  }

  factory DailyMacrosSummaryCreate.fromJson(Map<String, dynamic> json) {
    return DailyMacrosSummaryCreate(
      day: DateTime.parse(json['day']),
      calories: (json['calories'] as num).toDouble(),
      protein: (json['protein'] as num).toDouble(),
      carbs: (json['carbs'] as num).toDouble(),
      fat: (json['fat'] as num).toDouble(),
    );
  }
}
