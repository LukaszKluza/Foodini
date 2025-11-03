import 'package:frontend/models/diet_generation/daily_summary.dart';
import 'package:frontend/models/diet_generation/meal_info.dart';
import 'package:frontend/models/diet_generation/meal_status.dart';
import 'package:frontend/models/diet_generation/meal_type.dart';

/// Bazowa klasa eventów
abstract class DailySummaryEvent {}

/// Pobranie podsumowania dla danego dnia
class GetDailySummary extends DailySummaryEvent {
  final DateTime day;

  GetDailySummary(this.day);
}

/// Aktualizacja posiłku (np. zmiana makr, nazwy itp.)
class UpdateMeal extends DailySummaryEvent {
  final MealType mealType;
  final MealInfo updatedMeal;

  UpdateMeal({
    required this.mealType,
    required this.updatedMeal,
  });
}

/// Zmiana statusu konkretnego posiłku (np. `to_eat → eaten`)
class ChangeMealStatus extends DailySummaryEvent {
  final MealType mealType;
  final MealStatus newStatus; // lub MealStatus jeśli chcesz używać enuma bezpośrednio

  ChangeMealStatus({
    required this.mealType,
    required this.newStatus,
  });
}

/// Przywrócenie poprzedniego stanu po błędzie (np. po nieudanym update)
class RestoreDailySummaryAfterFailure extends DailySummaryEvent {
  final DailySummary previousSummary;

  RestoreDailySummaryAfterFailure(this.previousSummary);
}

/// Reset stanu do początkowego (np. po wylogowaniu)
class ResetDailySummary extends DailySummaryEvent {}
