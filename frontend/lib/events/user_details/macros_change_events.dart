import 'package:frontend/models/user_details/macros.dart';
import 'package:frontend/models/user_details/predicted_calories.dart';

abstract class MacrosChangeEvent {}

class LoadInitialMacros extends MacrosChangeEvent {}

class SetPredictedCalories extends MacrosChangeEvent {
  final PredictedCalories predictedCalories;
  SetPredictedCalories(this.predictedCalories);
}

class SubmitMacrosChange extends MacrosChangeEvent {
  final Macros macros;
  SubmitMacrosChange(this.macros);
}

class ResetMacrosChangeBloc extends MacrosChangeEvent {}
