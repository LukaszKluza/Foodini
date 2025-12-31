class DailyCaloriesStat {
  final DateTime day;
  final int calories;

  DailyCaloriesStat({required this.day, required this.calories});

  factory DailyCaloriesStat.fromJson(Map<String, dynamic> json) {
    return DailyCaloriesStat(
      day: DateTime.parse(json['day'] as String),
      calories: json['calories'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
    'day': day.toIso8601String().split('T').first,
    'calories': calories,
  };
}

class UserStatistics {
  final int targetCalories;
  final List<DailyCaloriesStat> weeklyCaloriesConsumption;

  UserStatistics({required this.targetCalories, required this.weeklyCaloriesConsumption});

  factory UserStatistics.fromJson(Map<String, dynamic> json) {
    final List<dynamic> list = json['weekly_calories_consumption'] ?? [];
    return UserStatistics(
      targetCalories: json['target_calories'] as int,
      weeklyCaloriesConsumption: list
          .map((e) => DailyCaloriesStat.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'target_calories': targetCalories,
    'weekly_calories_consumption': weeklyCaloriesConsumption.map((e) => e.toJson()).toList(),
  };
}
