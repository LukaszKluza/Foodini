import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/api_exception.dart';
import 'package:frontend/events/diet_generation/daily_summary_events.dart';
import 'package:frontend/l10n/app_localizations.dart';
import 'package:frontend/models/diet_generation/daily_summary.dart';
import 'package:frontend/models/diet_generation/meal_info_update_request.dart';
import 'package:frontend/models/processing_status.dart';
import 'package:frontend/repository/diet_generation/diet_generation_repository.dart';
import 'package:frontend/repository/user/user_storage.dart';
import 'package:frontend/states/diet_generation/daily_summary_states.dart';
import 'package:frontend/utils/diet_generation/meals_generation_notification.dart';
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
    emit(
      state.copyWith(
        gettingDailySummaryStatus: ProcessingStatus.gettingOnGoing,
      ),
    );

    try {
      final summary = await dietGenerationRepository.getDailySummary(
        event.day,
        UserStorage().getUserId!,
      );

      _emitGettingDailySummaryStatus(summary, emit);
    } on ApiException catch (error) {
      emit(
        state.copyWith(
          gettingDailySummaryStatus: ProcessingStatus.gettingFailure,
          errorCode: error.statusCode,
          errorData: error.data,
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
        state.copyWith(
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
    emit(
      state.copyWith(
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
        state.copyWith(
          dailySummary: updatedSummary,
          changingMealStatus: ProcessingStatus.submittingSuccess,
        ),
      );
    } on ApiException catch (error) {
      emit(
        state.copyWith(
          changingMealStatus: ProcessingStatus.submittingFailure,
          errorCode: error.statusCode,
          getMessage:
              (context) =>
                  ExceptionConverter.formatErrorMessage(error.data, context),
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
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
    emit(
      state.copyWith(updatingMealDetails: ProcessingStatus.submittingOnGoing),
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
        state.copyWith(
          dailySummary: updatedSummary,
          updatingMealDetails: ProcessingStatus.submittingSuccess,
        ),
      );
    } on ApiException catch (error) {
      emit(
        state.copyWith(
          updatingMealDetails: ProcessingStatus.submittingFailure,
          errorCode: error.statusCode,
          getMessage:
              (context) =>
                  ExceptionConverter.formatErrorMessage(error.data, context),
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          updatingMealDetails: ProcessingStatus.submittingFailure,
          getMessage: (context) => error.toString(),
        ),
      );
    }
  }

  Future<void> _onGenerateMealPlan(
    GenerateMealPlan event,
    Emitter<DailySummaryState> emit,
  ) async {
    emit(
      state.copyWith(
        day: event.day,
        processingStatus: ProcessingStatus.submittingOnGoing,
        getNotification: null,
      ),
    );

    try {
      final userId = UserStorage().getUserId!;

      await dietGenerationRepository.generateMealPlan(userId, event.day);

      emit(
        state.copyWith(
          processingStatus: ProcessingStatus.submittingSuccess,
          getNotification: (context) =>  MealsGenerationNotification(
            message: '${AppLocalizations.of(context)!.mealsGeneratedSuccessfully} '
                '${AppLocalizations.of(context)!.forSomething} ${event.day.day}.${event.day.month}.${event.day.year}',
            isError: false,
          ),
        ),
      );

      final summary = await dietGenerationRepository.getDailySummary(
        event.day,
        userId,
      );

      _emitGettingDailySummaryStatus(summary, emit);
    } on ApiException catch (error) {
      emit(
        state.copyWith(
          processingStatus: ProcessingStatus.submittingFailure,
          errorCode: error.statusCode,
          errorData: error.data,
          getMessage:
              (context) =>
                  ExceptionConverter.formatErrorMessage(error.data, context),
          getNotification: (context) => MealsGenerationNotification(
            message: '${AppLocalizations.of(context)!.error} ${AppLocalizations.of(context)!.whileMealsGeneration} '
                '${AppLocalizations.of(context)!.forSomething} ${event.day.day}.${event.day.month}.${event.day.year}: ${error.data}',
            isError: true,
          ),
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          processingStatus: ProcessingStatus.submittingFailure,
          getMessage: (context) => error.toString(),
          getNotification: (context) => MealsGenerationNotification(
            message: '${AppLocalizations.of(context)!.unknownError} ${AppLocalizations.of(context)!.whileMealsGeneration} '
                '${AppLocalizations.of(context)!.forSomething} ${event.day.day}.${event.day.month}.${event.day.year}: ${error.toString()}',
            isError: true,
          ),
        ),
      );
    }
  }

  void _emitGettingDailySummaryStatus(DailySummary summary, Emitter<DailySummaryState> emit) {
    if (summary.meals.isEmpty) {
      emit(
        state.copyWith(
          dailySummary: summary,
          gettingDailySummaryStatus: ProcessingStatus.gettingFailure,
        ),
      );
    } else {
      emit(
        state.copyWith(
          dailySummary: summary,
          gettingDailySummaryStatus: ProcessingStatus.gettingSuccess,
        ),
      );
    }
  }
}
