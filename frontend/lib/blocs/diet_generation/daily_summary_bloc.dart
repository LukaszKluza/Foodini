import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/api_exception.dart';
import 'package:frontend/events/diet_generation/daily_summary_events.dart';
import 'package:frontend/models/diet_generation/daily_summary.dart';
import 'package:frontend/models/diet_generation/meal_info_update_request.dart';
import 'package:frontend/models/processing_status.dart';
import 'package:frontend/repository/diet_generation/diet_generation_repository.dart';
import 'package:frontend/repository/user/user_storage.dart';
import 'package:frontend/states/diet_generation/daily_summary_states.dart';

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
    Emitter<DailySummaryState> emit
  ) async {
    final currentState = state;
    emit(currentState.copyWith(gettingDailySummaryStatus: ProcessingStatus.gettingOnGoing));

    try {
      final summary = await dietGenerationRepository.getDailySummary(event.day, UserStorage().getUserId!);

      emit(currentState.copyWith(gettingDailySummaryStatus: ProcessingStatus.gettingSuccess, dailySummary: summary));

    } on ApiException catch (e) {
      print('kaka');
      emit(currentState.copyWith(gettingDailySummaryStatus: ProcessingStatus.gettingFailure));

    } catch (e) {
      emit(currentState.copyWith(gettingDailySummaryStatus: ProcessingStatus.gettingFailure));
    }
  }

  Future<void> _onChangeMealStatus(
    ChangeMealStatus event,
    Emitter<DailySummaryState> emit
  ) async {
    final currentState = state;

    emit(currentState.copyWith(changingMealStatus: ProcessingStatus.submittingOnGoing));

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

      emit(currentState.copyWith(dailySummary: updatedSummary, changingMealStatus: ProcessingStatus.submittingSuccess));
    } on ApiException catch (e) {
      emit(currentState.copyWith(changingMealStatus: ProcessingStatus.submittingFailure));
    } catch (e) {
      emit(currentState.copyWith(changingMealStatus: ProcessingStatus.submittingFailure));
    }
  }

  Future<void> _onUpdateMeal(
    UpdateMeal event,
    Emitter<DailySummaryState> emit
  ) async {
    final currentState = state;

    emit(currentState.copyWith(updatingMeal: ProcessingStatus.submittingOnGoing));

    try {

      await dietGenerationRepository.addCustomMeal(
        event.customMealUpdateRequest,
        UserStorage().getUserId!,
      );

      final updatedSummary = await dietGenerationRepository.getDailySummary(
        event.customMealUpdateRequest.day,
        UserStorage().getUserId!,
      );

      emit(currentState.copyWith(dailySummary: updatedSummary, updatingMeal: ProcessingStatus.submittingSuccess));
    } on ApiException catch (e) {
      emit(currentState.copyWith(updatingMeal: ProcessingStatus.submittingFailure));

    } catch (e) {
      emit(currentState.copyWith(updatingMeal: ProcessingStatus.submittingOnGoing));
    }
  }

  Future<void> _onGenerateMealPlan(
    GenerateMealPlan event,
    Emitter<DailySummaryState> emit
  ) async {
    final currentState = state;

    print(currentState.runtimeType);

    // if (currentState is DailySummaryError) {
    //   emit(currentState.copyWith(generatingStatus: true));
    //
    //   print(currentState.error);
    //   print(currentState.message);
    // }

    emit(currentState.copyWith(day: event.day, processingStatus: ProcessingStatus.submittingOnGoing));

    try {
      final userId = UserStorage().getUserId!;

      await dietGenerationRepository.generateMealPlan(
        userId,
        event.day,
      );

      final summary = await dietGenerationRepository.getDailySummary(event.day, userId);

      emit(currentState.copyWith(dailySummary: summary, processingStatus: ProcessingStatus.submittingSuccess));

    } on ApiException catch (e) {
      print(e);
      emit(currentState.copyWith(processingStatus: ProcessingStatus.submittingFailure));
    } catch (e) {
      emit(currentState.copyWith(processingStatus: ProcessingStatus.submittingFailure));
    }
  }
}
