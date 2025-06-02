import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/events/user_details/diet_form_events.dart';
import 'package:frontend/states/diet_form_states.dart';

class DietFormBloc extends Bloc<DietFormEvent, DietFormState> {
  DietFormBloc() : super(DietFormState()) {
    on<UpdateGender>((event, emit) {
      emit(state.copyWith(gender: event.gender));
    });
    on<UpdateHeight>((event, emit) {
      emit(state.copyWith(height: event.height));
    });
    on<UpdateWeight>((event, emit) {
      emit(state.copyWith(weight: event.weight));
    });
    on<UpdateDateOfBirth>((event, emit) {
      emit(state.copyWith(dateOfBirth: event.dateOfBirth));
    });
    on<UpdateDietType>((event, emit) {
      emit(state.copyWith(dietType: event.dietType));
    });
    on<UpdateAllergies>((event, emit) {
      emit(state.copyWith(allergies: event.allergies));
    });
    on<UpdateDietGoal>((event, emit) {
      emit(state.copyWith(dietGoal: event.dietGoal));
    });
    on<UpdateMealsPerDay>((event, emit) {
      emit(state.copyWith(mealsPerDay: event.mealsPerDay));
    });
    on<UpdateDietIntensity>((event, emit) {
      emit(state.copyWith(dietIntensity: event.dietIntensity));
    });
    on<UpdateActivityLevel>((event, emit) {
      emit(state.copyWith(activityLevel: event.activityLevel));
    });
    on<UpdateStressLevel>((event, emit) {
      emit(state.copyWith(stressLevel: event.stressLevel));
    });
    on<UpdateSleepQuality>((event, emit) {
      emit(state.copyWith(sleepQuality: event.sleepQuality));
    });
    on<UpdateMusclePercentage>((event, emit) {
      emit(state.copyWith(musclePercentage: event.musclePercentage));
    });
    on<UpdateWaterPercentage>((event, emit) {
      emit(state.copyWith(waterPercentage: event.waterPercentage));
    });
    on<UpdateFatPercentage>((event, emit) {
      emit(state.copyWith(fatPercentage: event.fatPercentage));
    });

    on<SubmitForm>(_onSubmitForm);
  }

  Future<void> _onSubmitForm(
    SubmitForm event,
    Emitter<DietFormState> emit,
  ) async {
    emit(state.copyWith(isSubmitting: true, errorMessage: null));

    try {
      // TODO here add comunication with backend:
      emit(state.copyWith(isSubmitting: false, isSuccess: true));
    } catch (e) {
      emit(state.copyWith(
        isSubmitting: false,
        errorMessage: 'Submit failed: ${e.toString()}',
      ));
    }
  }
}
