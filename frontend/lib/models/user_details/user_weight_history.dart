class UserWeightHistory {
  final double weightKg;
  final DateTime day;

  UserWeightHistory({required this.weightKg, required this.day});

  factory UserWeightHistory.fromJson(Map<String, dynamic> json) {
    return UserWeightHistory(
      weightKg: (json['weight_kg'] as num).toDouble(),
      day: DateTime.parse(json['day'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'weight_kg': weightKg,
      'day': day.toIso8601String().split('T').first,
    };
  }
}
