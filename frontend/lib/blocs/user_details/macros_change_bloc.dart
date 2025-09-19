import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/api_exception.dart';
import 'package:frontend/events/user_details/macros_change_events.dart';
import 'package:frontend/l10n/app_localizations.dart';
import 'package:frontend/models/submitting_status.dart';
import 'package:frontend/repository/user/user_storage.dart';
import 'package:frontend/repository/user_details/user_details_repository.dart';
import 'package:frontend/states/macros_change_states.dart';
import 'package:frontend/utils/exception_converter.dart';
import 'package:uuid/uuid.dart';

class MacrosChangeBloc extends Bloc<MacrosChangeEvent, MacrosChangeState> {
  final UserDetailsRepository userDetailsRepository;

  MacrosChangeBloc(this.userDetailsRepository) : super(MacrosChangeState()) {
    on<LoadInitialMacros>(_onLoadInitialMacros);

    on<SetPredictedCalories>((event, emit) {
      emit(state.copyWith(predictedCalories: event.predictedCalories));
    });
    on<SubmitMacrosChange>(_onSubmitMacrosChange);
    on<RefreshMacrosBloc>((event, emit) {
      emit(state.copyWith(uuid: Uuid().v4()));
    });
    on<ResetProcessingStatus>((event, emit) {
      emit(state.copyWith(processingStatus: ProcessingStatus.emptyProcessingStatus));
    });
  }

  Future<void> _onLoadInitialMacros(
    LoadInitialMacros event,
    Emitter<MacrosChangeState> emit,
  ) async {
    emit(state.copyWith(processingStatus: ProcessingStatus.gettingOnGoing));
    try {
      final userId = UserStorage().getUserId!;
      final initialMacros = await userDetailsRepository.getCaloriesPrediction(
        userId,
      );

      emit(state.copyWith(predictedCalories: initialMacros, processingStatus: ProcessingStatus.gettingSuccess));
    } on ApiException catch (error) {
      emit(
        state.copyWith(
          getMessage:
              (context) =>
                  ExceptionConverter.formatErrorMessage(error, context),
          errorCode: error.statusCode
        ),
      );
    }
  }

  Future<void> _onSubmitMacrosChange(
    SubmitMacrosChange event,
    Emitter<MacrosChangeState> emit,
  ) async {
    emit(
      state.copyWith(
        macros: event.macros,
        processingStatus: ProcessingStatus.submittingOnGoing,
      ),
    );

    //TODO Test it. Question for reviewer/tester it is possible?
    if (state.macros == null) {
      emit(
        state.copyWith(
          getMessage:
              (context) => AppLocalizations.of(context)!.fillAllNecessaryFields,
        ),
      );
      return;
    }

    try {
      final userId = UserStorage().getUserId!;
      final updatedCalories = await userDetailsRepository.submitMacrosChange(
        state.macros!,
        userId,
      );

      emit(
        state.copyWith(
          processingStatus: ProcessingStatus.submittingSuccess,
          predictedCalories: updatedCalories,
        ),
      );
    } on ApiException catch (error) {
      emit(
        state.copyWith(
          processingStatus: ProcessingStatus.submittingFailure,
          getMessage:
              (context) =>
                  ExceptionConverter.formatErrorMessage(error, context),
        ),
      );
    }
  }
}
