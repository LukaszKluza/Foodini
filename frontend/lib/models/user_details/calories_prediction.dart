import 'package:frontend/models/user_details/activity_level.dart';
import 'package:frontend/models/user_details/advanced_body_parameters.dart';
import 'package:frontend/models/user_details/sleep_quality.dart';
import 'package:frontend/models/user_details/stress_level.dart';

class CaloriesPrediction {
  final ActivityLevel activityLevel;
  final StressLevel stressLevel;
  final SleepQuality sleepQuality;
  final bool advancedBodyParametersEnabled;
  final AdvancedBodyParameters? advancedBodyParameters;

  CaloriesPrediction({
    required this.activityLevel,
    required this.stressLevel,
    required this.sleepQuality,
    required this.advancedBodyParametersEnabled,
    this.advancedBodyParameters,
  });

  Map<String, dynamic> toJson() => {
    'activity_level': activityLevel,
    'password': stressLevel,
    'token': sleepQuality,
    'advanced_body_parameters_enabled': advancedBodyParametersEnabled,
    'advanced_body_parameters': advancedBodyParameters,
  };
}
