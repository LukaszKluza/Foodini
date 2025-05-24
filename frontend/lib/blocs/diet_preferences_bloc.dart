import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/states/diet_preferences_states.dart';

class DietPreferencesBloc extends Bloc<DietPreferencesBloc, DietPreferencesStates> {
  DietPreferencesBloc()
    : super(DietPreferencesInitial());
}
