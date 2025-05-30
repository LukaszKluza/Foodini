import 'package:frontend/models/user_details/calories_prediction.dart';

abstract class CaloriesPredictionEvent {}

class CaloriesPredictionSubmitted extends CaloriesPredictionEvent {
  final CaloriesPrediction request;

  CaloriesPredictionSubmitted(this.request);
}
