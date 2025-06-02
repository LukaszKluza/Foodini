import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/api_exception.dart';
import 'package:frontend/events/user_details/diet_form_events.dart';
import 'package:frontend/models/user_details/diet_form.dart';
import 'package:frontend/repository/user/user_storage.dart';
import 'package:frontend/repository/user_details/user_details_repository.dart';
import 'package:frontend/states/diet_form_states.dart';

class DietFormBloc extends Bloc<DietFormEvent, DietFormState> {
  final UserDetailsRepository userDetailsRepository;

  DietFormBloc(this.userDetailsRepository) : super(DietFormSubmit()) {
    on<UpdateGender>((event, emit) {
      final currentState = state as DietFormSubmit;
      emit(currentState.copyWith(gender: event.gender));
    });

    on<UpdateHeight>((event, emit) {
      final currentState = state as DietFormSubmit;
      emit(currentState.copyWith(height: event.height));
    });

    on<UpdateWeight>((event, emit) {
      final currentState = state as DietFormSubmit;
      emit(currentState.copyWith(weight: event.weight));
    });

    on<UpdateDateOfBirth>((event, emit) {
      final currentState = state as DietFormSubmit;
      emit(currentState.copyWith(dateOfBirth: event.dateOfBirth));
    });

    on<UpdateDietType>((event, emit) {
      final currentState = state as DietFormSubmit;
      emit(currentState.copyWith(dietType: event.dietType));
    });

    on<UpdateAllergies>((event, emit) {
      final currentState = state as DietFormSubmit;
      emit(currentState.copyWith(allergies: event.allergies));
    });

    on<UpdateDietGoal>((event, emit) {
      final currentState = state as DietFormSubmit;
      emit(currentState.copyWith(dietGoal: event.dietGoal));
    });

    on<UpdateMealsPerDay>((event, emit) {
      final currentState = state as DietFormSubmit;
      emit(currentState.copyWith(mealsPerDay: event.mealsPerDay));
    });

    on<UpdateDietIntensity>((event, emit) {
      final currentState = state as DietFormSubmit;
      emit(currentState.copyWith(dietIntensity: event.dietIntensity));
    });

    on<UpdateActivityLevel>((event, emit) {
      final currentState = state as DietFormSubmit;
      emit(currentState.copyWith(activityLevel: event.activityLevel));
    });

    on<UpdateStressLevel>((event, emit) {
      final currentState = state as DietFormSubmit;
      emit(currentState.copyWith(stressLevel: event.stressLevel));
    });

    on<UpdateSleepQuality>((event, emit) {
      final currentState = state as DietFormSubmit;
      emit(currentState.copyWith(sleepQuality: event.sleepQuality));
    });

    on<UpdateMusclePercentage>((event, emit) {
      final currentState = state as DietFormSubmit;
      emit(currentState.copyWith(musclePercentage: event.musclePercentage));
    });

    on<UpdateWaterPercentage>((event, emit) {
      final currentState = state as DietFormSubmit;
      emit(currentState.copyWith(waterPercentage: event.waterPercentage));
    });

    on<UpdateFatPercentage>((event, emit) {
      final currentState = state as DietFormSubmit;
      emit(currentState.copyWith(fatPercentage: event.fatPercentage));
    });

    on<SubmitForm>(_onSubmitForm);
  }

  Future<void> _onSubmitForm(
    SubmitForm event,
    Emitter<DietFormState> emit,
  ) async {
    final currentState = state as DietFormSubmit;
    emit(currentState.copyWith(isSubmitting: true, errorMessage: null));

    try {
      final dietForm = DietForm(
        gender: currentState.gender!,
        height: currentState.height!,
        weight: currentState.weight!,
        dateOfBirth: currentState.dateOfBirth!,
        dietType: currentState.dietType!,
        allergies: currentState.allergies!,
        dietGoal: currentState.dietGoal!,
        mealsPerDay: currentState.mealsPerDay!,
        dietIntensity: currentState.dietIntensity!,
        activityLevel: currentState.activityLevel!,
        stressLevel: currentState.stressLevel!,
        sleepQuality: currentState.sleepQuality!,
        musclePercentage: currentState.musclePercentage,
        fatPercentage: currentState.fatPercentage,
        waterPercentage: currentState.waterPercentage,
      );

      var userId = UserStorage().getUserId!;
      await userDetailsRepository.submitDietForm(dietForm, userId);

      emit(DietFormSubmitSuccess());
    } on ApiException catch (e) {
      emit(DietFormSubmitFailure(e));
    }
  }
}
