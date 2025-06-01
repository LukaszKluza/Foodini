import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/events/user_details/diet_form_events.dart';
import 'package:frontend/models/user_details/diet_form.dart';
import 'package:frontend/repository/user/user_storage.dart';
import 'package:frontend/repository/user_details/user_details_repository.dart';
import 'package:frontend/states/diet_form_states.dart';

class DietFormBloc extends Bloc<DietFormEvent, DietFormState> {
  final UserDetailsRepository userDetailsRepository;

  DietFormBloc(this.userDetailsRepository) : super(DietFormState()) {
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

    print('''
      DietFormState:
        gender: ${state.gender}
        height: ${state.height}
        weight: ${state.weight}
        dateOfBirth: ${state.dateOfBirth}

        dietType: ${state.dietType}
        allergies: ${state.allergies}
        dietGoal: ${state.dietGoal}
        mealsPerDay: ${state.mealsPerDay}
        dietIntensity: ${state.dietIntensity}

        activityLevel: ${state.activityLevel}
        stressLevel: ${state.stressLevel}
        sleepQuality: ${state.sleepQuality}
        musclePercentage: ${state.musclePercentage}
        fatPercentage: ${state.fatPercentage}
        waterPercentage: ${state.waterPercentage}

        isSubmitting: ${state.isSubmitting}
        isSuccess: ${state.isSuccess}
        errorMessage: ${state.errorMessage}
      ''');

    try {
      final dietForm = DietForm(
        gender: state.gender!,
        height: state.height!,
        weight: state.weight!,
        dateOfBirth: state.dateOfBirth!,
        dietType: state.dietType!,
        allergies: state.allergies!,
        dietGoal: state.dietGoal!,
        mealsPerDay: state.mealsPerDay!,
        dietIntensity: state.dietIntensity!,
        activityLevel: state.activityLevel!,
        stressLevel: state.stressLevel!,
        sleepQuality: state.sleepQuality!,
        musclePercentage: state.musclePercentage,
        fatPercentage: state.fatPercentage,
        waterPercentage: state.waterPercentage,
      );

      var userId = UserStorage().getUserId!;
      await userDetailsRepository.submitDietForm(dietForm, userId);

      emit(state.copyWith(isSubmitting: false, isSuccess: true));
    } catch (e) {
      emit(
        state.copyWith(
          isSubmitting: false,
          errorMessage: 'Submit failed: ${e.toString()}',
        ),
      );
    }
  }
}
