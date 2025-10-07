import 'package:frontend/models/user_details/macros.dart';

class PredictedCalories {
  final int bmr;
  final int tdee;
  final int targetCalories;
  final int? dietDurationDays;
  final Macros predictedMacros;

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
      predictedMacros: Macros.fromJson(json['predicted_macros']),
    );
  }

  Map<String, dynamic> toJson() => {
    'bmr': bmr,
    'tdee': tdee,
    'target_calories': targetCalories,
    'diet_duration_days': dietDurationDays,
    'predicted_macros': predictedMacros.toJson(),
  };

  @override
  String toString() {
    return 'PredictedCalories(bmr: $bmr, tdee: $tdee, targetCalories: $targetCalories, '
        'dietDurationDays: $dietDurationDays, predictedMacros: $predictedMacros)';
  }
}
