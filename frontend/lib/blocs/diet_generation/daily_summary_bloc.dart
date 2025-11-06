import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/api_exception.dart';
import 'package:frontend/events/diet_generation/daily_summary_events.dart';
import 'package:frontend/models/diet_generation/custom_meal_update_request.dart';
import 'package:frontend/models/diet_generation/meal_info_update_request.dart';
import 'package:frontend/repository/diet_generation/diet_generation_repository.dart';
import 'package:frontend/repository/user/user_storage.dart';
import 'package:frontend/states/diet_generation/daily_summary_states.dart';

class DailySummaryBloc extends Bloc<DailySummaryEvent, DailySummaryState> {
  final DietGenerationRepository dietGenerationRepository;

  DailySummaryBloc(this.dietGenerationRepository) : super(DailySummaryInit()) {
    on<GetDailySummary>(_onGetDailySummary);
    on<ChangeMealStatus>(_onChangeMealStatus);
    on<UpdateMeal>(_onUpdateMeal);
    on<ResetDailySummary>((event, emit) {
      emit(DailySummaryInit());
    });
  }

  Future<void> _onGetDailySummary(
    GetDailySummary event,
    Emitter<DailySummaryState> emit
  ) async {
    emit(DailySummaryLoading());

    try {
      final summary = await dietGenerationRepository.getDailySummary(event.day, UserStorage().getUserId!);

      emit(DailySummaryLoaded(
        dailySummary: summary
      ));
    } on ApiException catch (e) {
      emit(DailySummaryError(
        message: 'Unable to fetch daily summary',
        error: e,
      ));
    } catch (e) {
      emit(DailySummaryError(message: e.toString()));
    }
  }

  Future<void> _onChangeMealStatus(
    ChangeMealStatus event,
    Emitter<DailySummaryState> emit
  ) async {
    final currentState = state;

    if (currentState is! DailySummaryLoaded) {
      return; 
    }

    emit(currentState.copyWith(isChangingMealStatus: true));

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

      emit(currentState.copyWith(
        dailySummary: updatedSummary,
        isChangingMealStatus: false,
      ));
    } on ApiException catch (e) {
      emit(DailySummaryError(
        message: 'Failed to update meal status',
        error: e,
      ));
    } catch (e) {
      emit(DailySummaryError(message: e.toString()));
    }
  }

  Future<void> _onUpdateMeal(
    UpdateMeal event,
    Emitter<DailySummaryState> emit
  ) async {
    final currentState = state;

    if (currentState is! DailySummaryLoaded) {
      return; 
    }

    emit(currentState.copyWith(isChangingMealStatus: true));

    try {

      await dietGenerationRepository.addCustomMeal(
        event.customMealUpdateRequest,
        UserStorage().getUserId!,
      );

      final updatedSummary = await dietGenerationRepository.getDailySummary(
        event.customMealUpdateRequest.day,
        UserStorage().getUserId!,
      );


      emit(currentState.copyWith(
        dailySummary: updatedSummary,
        isChangingMealStatus: false,
      ));
    } on ApiException catch (e) {
      emit(DailySummaryError(
        message: 'Failed to add custom meal $e',
        error: e,
      ));
    } catch (e) {
      emit(DailySummaryError(message: e.toString()));
    }
  }
}
