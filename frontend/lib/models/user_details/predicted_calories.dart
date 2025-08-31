import 'package:frontend/models/user_details/predicted_macros.dart';

class PredictedCalories {
  final int bmr;
  final int tdee;
  final int targetCalories;
  final int? dietDurationDays;
  final PredictedMacros predictedMacros;

  PredictedCalories({
    required this.bmr,
    required this.tdee,
    required this.targetCalories,
    this.dietDurationDays,
    required this.predictedMacros,
  });

  factory PredictedCalories.fromJson(Map<String, dynamic> json) {
    return PredictedCalories(
      bmr: json['bmr'],
      tdee: json['tdee'],
      targetCalories: json['target_calories'],
      dietDurationDays: json['diet_duration_days'],
      predictedMacros: PredictedMacros.fromJson(json['predicted_macros']),
    );
  }
}
