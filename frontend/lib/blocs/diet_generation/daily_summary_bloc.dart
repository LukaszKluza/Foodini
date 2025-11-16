import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/api_exception.dart';
import 'package:frontend/events/diet_generation/daily_summary_events.dart';
import 'package:frontend/l10n/app_localizations.dart';
import 'package:frontend/models/diet_generation/meal_info_update_request.dart';
import 'package:frontend/models/processing_status.dart';
import 'package:frontend/repository/diet_generation/diet_generation_repository.dart';
import 'package:frontend/repository/user/user_storage.dart';
import 'package:frontend/states/diet_generation/daily_summary_states.dart';
import 'package:frontend/utils/exception_converter.dart';

class DailySummaryBloc extends Bloc<DailySummaryEvent, DailySummaryState> {
  final DietGenerationRepository dietGenerationRepository;

  DailySummaryBloc(this.dietGenerationRepository) : super(DailySummaryState()) {
    on<GetDailySummary>(_onGetDailySummary);
    on<ChangeMealStatus>(_onChangeMealStatus);
    on<UpdateMeal>(_onUpdateMeal);
    on<ResetDailySummary>((event, emit) {
      emit(DailySummaryState());
    });
    on<GenerateMealPlan>(_onGenerateMealPlan);
  }

  Future<void> _onGetDailySummary(
    GetDailySummary event,
    Emitter<DailySummaryState> emit,
  ) async {
    final currentState = state;
    emit(
      currentState.copyWith(
        gettingDailySummaryStatus: ProcessingStatus.gettingOnGoing,
      ),
    );

    try {
      final summary = await dietGenerationRepository.getDailySummary(
        event.day,
        UserStorage().getUserId!,
      );

      emit(
        currentState.copyWith(
          gettingDailySummaryStatus: ProcessingStatus.gettingSuccess,
          dailySummary: summary,
        ),
      );
    } on ApiException catch (error) {
      emit(
        currentState.copyWith(
          gettingDailySummaryStatus: ProcessingStatus.gettingFailure,
          errorCode: error.statusCode,
          getMessage: (context) {
            final message = ExceptionConverter.formatErrorMessage(error.data, context);

            return message == 'Unknown error'
                ? AppLocalizations.of(context)!.unknownError
                : AppLocalizations.of(context)!.planDoesNotExist;
          },
        ),
      );
    } catch (error) {
      emit(
        currentState.copyWith(
          gettingDailySummaryStatus: ProcessingStatus.gettingFailure,
          getMessage: (context) => error.toString(),
        ),
      );
    }
  }

  Future<void> _onChangeMealStatus(
    ChangeMealStatus event,
    Emitter<DailySummaryState> emit,
  ) async {
    final currentState = state;

    emit(
      currentState.copyWith(
        changingMealStatus: ProcessingStatus.submittingOnGoing,
      ),
    );

    try {
      final request = MealInfoUpdateRequest(
        day: event.day,
        mealId: event.mealId,
        mealStatus: event.status,
      );

      await dietGenerationRepository.updateDailySummaryMeals(
        request,
        UserStorage().getUserId!,
      );

      final updatedSummary = await dietGenerationRepository.getDailySummary(
        event.day,
        UserStorage().getUserId!,
      );

      emit(
        currentState.copyWith(
          dailySummary: updatedSummary,
          changingMealStatus: ProcessingStatus.submittingSuccess,
        ),
      );
    } on ApiException catch (error) {
      emit(
        currentState.copyWith(
          changingMealStatus: ProcessingStatus.submittingFailure,
          errorCode: error.statusCode,
          getMessage:
              (context) =>
                  ExceptionConverter.formatErrorMessage(error.data, context),
        ),
      );
    } catch (error) {
      emit(
        currentState.copyWith(
          changingMealStatus: ProcessingStatus.submittingFailure,
          getMessage: (context) => error.toString(),
        ),
      );
    }
  }

  Future<void> _onUpdateMeal(
    UpdateMeal event,
    Emitter<DailySummaryState> emit,
  ) async {
    final currentState = state;

    emit(
      currentState.copyWith(updatingMealStatus: ProcessingStatus.submittingOnGoing),
    );

    try {
      await dietGenerationRepository.addCustomMeal(
        event.customMealUpdateRequest,
        UserStorage().getUserId!,
      );

      final updatedSummary = await dietGenerationRepository.getDailySummary(
        event.customMealUpdateRequest.day,
        UserStorage().getUserId!,
      );

      emit(
        currentState.copyWith(
          dailySummary: updatedSummary,
          updatingMealStatus: ProcessingStatus.submittingSuccess,
        ),
      );
    } on ApiException catch (error) {
      emit(
        currentState.copyWith(
          updatingMealStatus: ProcessingStatus.submittingFailure,
          errorCode: error.statusCode,
          getMessage:
              (context) =>
                  ExceptionConverter.formatErrorMessage(error.data, context),
        ),
      );
    } catch (error) {
      emit(
        currentState.copyWith(
          updatingMealStatus: ProcessingStatus.submittingFailure,
          getMessage: (context) => error.toString(),
        ),
      );
    }
  }

  Future<void> _onGenerateMealPlan(
    GenerateMealPlan event,
    Emitter<DailySummaryState> emit,
  ) async {
    final currentState = state;

    emit(
      currentState.copyWith(
        day: event.day,
        processingStatus: ProcessingStatus.submittingOnGoing,
      ),
    );

    try {
      final userId = UserStorage().getUserId!;

      await dietGenerationRepository.generateMealPlan(userId, event.day);

      final summary = await dietGenerationRepository.getDailySummary(
        event.day,
        userId,
      );

      if (summary.meals.isEmpty) {
        emit(
          currentState.copyWith(
            dailySummary: summary,
            processingStatus: ProcessingStatus.submittingSuccess,
            gettingDailySummaryStatus: ProcessingStatus.gettingFailure,
          ),
        );
      } else {
        emit(
          currentState.copyWith(
            dailySummary: summary,
            processingStatus: ProcessingStatus.submittingSuccess,
            gettingDailySummaryStatus: ProcessingStatus.gettingSuccess,
          ),
        );
      }
    } on ApiException catch (error) {
      emit(
        currentState.copyWith(
          processingStatus: ProcessingStatus.submittingFailure,
          errorCode: error.statusCode,
          getMessage:
              (context) =>
                  ExceptionConverter.formatErrorMessage(error.data, context),
        ),
      );
    } catch (error) {
      emit(
        currentState.copyWith(
          processingStatus: ProcessingStatus.submittingFailure,
          getMessage: (context) => error.toString(),
        ),
      );
    }
  }
}
