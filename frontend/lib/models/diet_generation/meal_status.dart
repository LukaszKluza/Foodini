import 'package:collection/collection.dart';
import 'package:frontend/views/screens/diet_generation/daily_summary_screen.dart';

enum MealStatus {
  toEat(0, 'to_eat'),
  pending(1, 'pending'),
  eaten(2, 'eaten'),
  skipped(3, 'skipped');

  final int value;
  final String nameStr;

  const MealStatus(this.value, this.nameStr);

  String toJson() => nameStr;

  static MealStatus fromJson(String value) {
    return MealStatus.values.firstWhere(
      (e) => e.nameStr == value,
      orElse: () => throw ArgumentError('Unknown meal status: $value'),
    );
  }

  int toInt() => value;

  static MealStatus getNextStatus(Meal currentMeal, List<Meal> all) {
    final List<MealStatus> order = [
      MealStatus.eaten,
      MealStatus.skipped,
      MealStatus.toEat,
      MealStatus.pending,
    ];
    MealStatus current = currentMeal.mealStatus;

    final currentIndex = all.indexWhere((m) => m.type == currentMeal.type);

    bool noEatenFutureMeal() {
      final futureMeals = all.skip(currentIndex + 1);
      return !futureMeals.any((m) => m.mealStatus == MealStatus.eaten);
    }

     bool noPendingFutureMeal() {
      final futureMeals = all.skip(currentIndex + 1);
      return !futureMeals.any((m) => m.mealStatus == MealStatus.pending);
    }

    bool noPendingPreviousMeal() {
      final previousMeals = all.take(currentIndex);
      return !previousMeals.any((m) => m.mealStatus == MealStatus.pending);
    }

    bool condition(MealStatus status, MealStatus current) {
      switch (status) {
        case MealStatus.eaten:
          return noPendingPreviousMeal();
        case MealStatus.skipped:
          return true;
        case MealStatus.toEat:
          return noEatenFutureMeal() && noPendingFutureMeal();
        case MealStatus.pending:
          return noEatenFutureMeal() && noPendingPreviousMeal();
      }
    }

    final next = order
        .skipWhile((s) => s != current)
        .skip(1)
        .followedBy(order)
        .firstWhere((s) => condition(s, current), orElse: () => current);

    Meal? findNextMeal(bool Function(Meal m) test) =>
      all.skip(currentIndex + 1).firstWhereOrNull(test);

    if (current == MealStatus.pending) {
      final nextToEat = findNextMeal((m) => m.mealStatus == MealStatus.toEat);
      if (nextToEat != null) nextToEat.mealStatus = MealStatus.pending;
    }

    if (next == MealStatus.pending) {
      final nextPending = findNextMeal((m) => m.mealStatus == MealStatus.pending);
      if (nextPending != null) nextPending.mealStatus = MealStatus.toEat;
    }

    return next;
  }
}