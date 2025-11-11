import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/api_exception.dart';
import 'package:frontend/events/user_details/diet_form_events.dart';
import 'package:frontend/l10n/app_localizations.dart';
import 'package:frontend/models/user_details/diet_form.dart';
import 'package:frontend/repository/user/user_storage.dart';
import 'package:frontend/repository/user_details/user_details_repository.dart';
import 'package:frontend/states/diet_form_states.dart';
import 'package:frontend/utils/logger.dart';

class DietFormBloc extends Bloc<DietFormEvent, DietFormState> {
  final UserDetailsRepository userDetailsRepository;

  DietFormBloc(this.userDetailsRepository) : super(DietFormInit()) {
    on<UpdateGender>((event, emit) {
      if (state is DietFormSubmit) {
        final currentState = state as DietFormSubmit;
        emit(currentState.copyWith(gender: event.gender));
      }
    });

    on<UpdateHeight>((event, emit) {
      if (state is DietFormSubmit) {
        final currentState = state as DietFormSubmit;
        emit(currentState.copyWith(height: event.height));
      }
    });

    on<UpdateWeight>((event, emit) {
      if (state is DietFormSubmit) {
        final currentState = state as DietFormSubmit;
        emit(currentState.copyWith(weight: event.weight));
      }
    });

    on<UpdateDateOfBirth>((event, emit) {
      if (state is DietFormSubmit) {
        final currentState = state as DietFormSubmit;
        emit(currentState.copyWith(dateOfBirth: event.dateOfBirth));
      }
    });

    on<UpdateDietType>((event, emit) {
      if (state is DietFormSubmit) {
        final currentState = state as DietFormSubmit;
        emit(currentState.copyWith(dietType: event.dietType));
      }
    });

    on<UpdateDietStyle>((event, emit) {
      if (state is DietFormSubmit) {
        final currentState = state as DietFormSubmit;
        emit(currentState.copyWith(dietStyle: event.dietStyle));
      }
    });

    on<UpdateDietaryRestrictions>((event, emit) {
      if (state is DietFormSubmit) {
        final currentState = state as DietFormSubmit;
        emit(currentState.copyWith(allergies: event.dietaryRestrictions));
      }
    });

    on<UpdateDietGoal>((event, emit) {
      if (state is DietFormSubmit) {
        final currentState = state as DietFormSubmit;
        emit(currentState.copyWith(dietGoal: event.dietGoal));
      }
    });

    on<UpdateMealsPerDay>((event, emit) {
      if (state is DietFormSubmit) {
        final currentState = state as DietFormSubmit;
        emit(currentState.copyWith(mealsPerDay: event.mealsPerDay));
      }
    });

    on<UpdateDietIntensity>((event, emit) {
      if (state is DietFormSubmit) {
        final currentState = state as DietFormSubmit;
        emit(currentState.copyWith(dietIntensity: event.dietIntensity));
      }
    });

    on<UpdateActivityLevel>((event, emit) {
      if (state is DietFormSubmit) {
        final currentState = state as DietFormSubmit;
        emit(currentState.copyWith(activityLevel: event.activityLevel));
      }
    });

    on<UpdateStressLevel>((event, emit) {
      if (state is DietFormSubmit) {
        final currentState = state as DietFormSubmit;
        emit(currentState.copyWith(stressLevel: event.stressLevel));
      }
    });

    on<UpdateSleepQuality>((event, emit) {
      if (state is DietFormSubmit) {
        final currentState = state as DietFormSubmit;
        emit(currentState.copyWith(sleepQuality: event.sleepQuality));
      }
    });

    on<UpdateAdvancedParameters>((event, emit) {
      if (state is DietFormSubmit) {
        final currentState = state as DietFormSubmit;
        emit(
          currentState.copyWith(
            musclePercentage: event.musclePercentage,
            fatPercentage: event.fatPercentage,
            waterPercentage: event.waterPercentage,
          ),
        );
      }
    });

    on<RestoreDietFormStateAfterFailure>((event, emit) {
      emit(event.previousData);
    });

    on<DietFormResetRequested>((event, emit) {
      emit(DietFormSubmit.initial());
    });

    on<InitForm>(_onInitForm);

    on<SubmitForm>(_onSubmitForm);
  }

  Future<void> _onInitForm(InitForm event, Emitter<DietFormState> emit) async {
    final currentState =
        state is DietFormSubmit
            ? state as DietFormSubmit
            : DietFormSubmit.initial();

    emit(currentState);

    try {
      final userId = UserStorage().getUserId!;
      final dietPreferences = await userDetailsRepository.getDietPreferences(
        userId,
      );

      emit(DietFormSubmit.fromDietForm(dietPreferences));
    } on ApiException catch (e) {
      if (e.statusCode == 404) {
        emit(DietFormSubmit.initial());
        return;
      }
      logger.w('Unable to fetch user diet preferences');
      emit(currentState.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> _onSubmitForm(
    SubmitForm event,
    Emitter<DietFormState> emit,
  ) async {
    DietFormSubmit currentState;
    if (state is DietFormSubmit) {
      currentState = state as DietFormSubmit;
    } else {
      currentState = DietFormSubmit.initial();
    }
    emit(currentState.copyWith(isSubmitting: true, errorMessage: null));

    final requiredFields = [
      currentState.gender,
      currentState.height,
      currentState.weight,
      currentState.dateOfBirth,
      currentState.dietType,
      currentState.dietaryRestrictions,
      currentState.dietGoal,
      currentState.mealsPerDay,
      currentState.dietIntensity,
      currentState.activityLevel,
      currentState.stressLevel,
      currentState.sleepQuality,
    ];

    if (requiredFields.any((field) => field == null)) {
      emit(
        DietFormSubmitFailure(
          previousData: currentState,
          getMessage:
              (context) => AppLocalizations.of(context)!.fillAllNecessaryFields,
        ),
      );
      return;
    }

    try {
      final dietForm = DietForm(
        gender: currentState.gender!,
        height: currentState.height!,
        weight: currentState.weight!,
        dateOfBirth: currentState.dateOfBirth!,
        dietType: currentState.dietType!,
        dietStyle: currentState.dietStyle,
        dietaryRestrictions: currentState.dietaryRestrictions!,
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

      final userId = UserStorage().getUserId!;
      await userDetailsRepository.submitDietForm(dietForm, userId);

      final predicted = await userDetailsRepository.addCaloriesPrediction(
        userId,
      );

      emit(DietFormSubmitSuccess(predicted));
    } on ApiException catch (e) {
      emit(DietFormSubmitFailure(previousData: currentState, error: e));
    }
  }
}
