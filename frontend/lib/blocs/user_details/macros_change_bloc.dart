import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/api_exception.dart';
import 'package:frontend/events/user_details/macros_change_events.dart';
import 'package:frontend/l10n/app_localizations.dart';
import 'package:frontend/models/user_details/predicted_macros.dart';
import 'package:frontend/repository/user/user_storage.dart';
import 'package:frontend/repository/user_details/user_details_repository.dart';
import 'package:frontend/states/macros_change_states.dart';

class MacrosChangeBloc extends Bloc<MacrosChangeEvent, MacrosChangeState> {
  final UserDetailsRepository userDetailsRepository;

  MacrosChangeBloc(this.userDetailsRepository) : super(MacrosChangeSubmit()) {
    on<UpdateProtein>((event, emit) {
      final currentState = state as MacrosChangeSubmit;
      emit(currentState.copyWith(protein: event.protein));
    });

    on<UpdateFat>((event, emit) {
      final currentState = state as MacrosChangeSubmit;
      emit(currentState.copyWith(fat: event.fat));
    });

    on<UpdateCarbs>((event, emit) {
      final currentState = state as MacrosChangeSubmit;
      emit(currentState.copyWith(carbs: event.carbs));
    });

    on<MacrosChangeResetRequested>((event, emit) {
      emit(MacrosChangeSubmit.initial());
    });

    on<SubmitMacrosChange>(_onSubmitMacrosChange);
  }

  Future<void> _onSubmitMacrosChange(
    SubmitMacrosChange event,
    Emitter<MacrosChangeState> emit,
  ) async {
    final currentState = state as MacrosChangeSubmit;
    emit(currentState.copyWith(isSubmitting: true, errorMessage: null));

    final requiredFields = [
      currentState.protein,
      currentState.fat,
      currentState.carbs,
    ];

    if (requiredFields.any((field) => field == null)) {
      emit(
        MacrosChangeSubmitFailure(
          getMessage:
              (context) => AppLocalizations.of(context)!.fillAllNecessaryFields,
        ),
      );
      return;
    }

    try {
      final macrosChange = PredictedMacros(
        protein: currentState.protein!,
        fat: currentState.fat!,
        carbs: currentState.carbs!,
      );

      final userId = UserStorage().getUserId!;
      await userDetailsRepository.submitMacrosChange(macrosChange, userId);

      emit(MacrosChangeSubmitSuccess());
    } on ApiException catch (e) {
      emit(MacrosChangeSubmitFailure(error: e));
    }
  }
}
