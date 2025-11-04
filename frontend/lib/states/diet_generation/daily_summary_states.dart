import 'package:frontend/api_exception.dart';
import 'package:frontend/models/diet_generation/daily_summary.dart';

/// Bazowy stan — wszystkie stany dziedziczą po tym
abstract class DailySummaryState {}

/// Stan początkowy (np. zanim załadujemy dane)
class DailySummaryInit extends DailySummaryState {}

/// Stan ładowania danych (np. przy starcie ekranu)
class DailySummaryLoading extends DailySummaryState {}

/// Stan załadowanych danych
class DailySummaryLoaded extends DailySummaryState {
  final DailySummary dailySummary;
  final bool isUpdatingMeal;
  final bool isChangingMealStatus;

  DailySummaryLoaded({
    required this.dailySummary,
    this.isUpdatingMeal = false,
    this.isChangingMealStatus = false,
  });

  DailySummaryLoaded copyWith({
    DailySummary? dailySummary,
    bool? isUpdatingMeal,
    bool? isChangingMealStatus,
  }) {
    return DailySummaryLoaded(
      dailySummary: dailySummary ?? this.dailySummary,
      isUpdatingMeal: isUpdatingMeal ?? this.isUpdatingMeal,
      isChangingMealStatus:
          isChangingMealStatus ?? this.isChangingMealStatus,
    );
  }
}

/// Stan błędu — np. nie udało się pobrać danych z backendu
class DailySummaryError extends DailySummaryState {
  final String? message;
  final ApiException? error;

  DailySummaryError({this.message, this.error});
}

/// Stan sukcesu po akcji (np. po udanym update posiłku lub zmianie statusu)
class DailySummaryUpdateSuccess extends DailySummaryState {
  final DailySummary updatedSummary;
  final String? successMessage;

  DailySummaryUpdateSuccess({
    required this.updatedSummary,
    this.successMessage,
  });
}

/// Stan błędu po akcji (np. update posiłku nieudany)
class DailySummaryUpdateFailure extends DailySummaryState {
  final DailySummary previousSummary;
  final String? errorMessage;
  final ApiException? error;

  DailySummaryUpdateFailure({
    required this.previousSummary,
    this.errorMessage,
    this.error,
  });
}
