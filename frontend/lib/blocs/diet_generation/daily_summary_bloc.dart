import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/api_exception.dart';
import 'package:frontend/events/diet_generation/daily_summary_events.dart';
import 'package:frontend/models/diet_generation/daily_summary.dart';
import 'package:frontend/repository/diet_generation/diet_generation_repository.dart';
import 'package:frontend/repository/user/user_storage.dart';
import 'package:frontend/repository/user_details/user_details_repository.dart';
import 'package:frontend/states/diet_generation/daily_summary_states.dart';

class DailySummaryBloc extends Bloc<DailySummaryEvent, DailySummaryState> {
  final DietGenerationRepository dietGenerationRepository;

  DailySummaryBloc(this.dietGenerationRepository) : super(DailySummaryInit()) {
    on<GetDailySummary>(_onGetDailySummary);
  }

  Future<void> _onGetDailySummary(
    GetDailySummary event,
    Emitter<DailySummaryState> emit
  ) async {
    emit(DailySummaryLoading());

    try {
      final meals = await dietGenerationRepository.getDailySummaryMeals(event.day, UserStorage().getUserId!);
      final macros = await dietGenerationRepository.getDailySummaryMacros(event.day, UserStorage().getUserId!);

      emit(DailySummaryLoaded(
        dailySummary: DailySummary(
          day: event.day,
          meals: meals.meals,
          targetCalories: meals.targetCalories,
          targetProtein: meals.targetProtein,
          targetCarbs: meals.targetCarbs,
          targetFat: meals.targetFat,
          currentCalories: macros.calories,
          currentProtein: macros.protein,
          currentCarbs: macros.carbs,
          currentFat: macros.fat,
        )));
    } on ApiException catch (e) {
      emit(DailySummaryError(
        message: 'Unable to fetch daily summary',
        error: e,
      ));
    } catch (e) {
      emit(DailySummaryError(message: e.toString()));
    }
  }
}