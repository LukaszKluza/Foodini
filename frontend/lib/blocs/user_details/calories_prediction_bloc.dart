import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/events/user_details/calories_prediction_events.dart';
import 'package:frontend/states/calories_prediction_states.dart';

class CaloriesPredictionBloc extends Bloc<CaloriesPredictionEvent, CaloriesPredictionState> {
  CaloriesPredictionBloc()
    : super(CaloriesPredictionInitial());
}
