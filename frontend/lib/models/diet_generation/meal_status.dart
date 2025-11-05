import 'package:frontend/models/diet_generation/meal_info.dart';
import 'package:frontend/models/diet_generation/meal_type.dart';

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

  // Location: Wherever your MealStatus class is defined (e.g., meal_status.dart)

  static MealStatus getNextStatus(
      MealType currentType,
      Map<MealType, MealInfo> allMeals,
  ) {
      final List<MealType> order = MealType.values;
      final currentMeal = allMeals[currentType]!;
      final currentStatus = currentMeal.status;
      final currentIndex = order.indexOf(currentType);

      bool noEatenFutureMeal() {
        final futureMeals = order.skip(currentIndex + 1);
        return !futureMeals.any(
          (type) => allMeals[type]?.status == MealStatus.eaten,
        );
      }

      bool noPendingFutureMeal() {
        final futureMeals = order.skip(currentIndex + 1);
        return !futureMeals.any(
          (type) => allMeals[type]?.status == MealStatus.pending,
        );
      }

      bool noPendingPreviousMeal() {
        final previousMeals = order.take(currentIndex);
        return !previousMeals.any(
          (type) => allMeals[type]?.status == MealStatus.pending,
        );
      }

      // PARAMETER CHANGE: Removed the unused 'current' argument
      bool condition(MealStatus status /*, MealStatus current */) {
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

      final statusOrder = [
        MealStatus.eaten,
        MealStatus.skipped,
        MealStatus.toEat,
        MealStatus.pending,
      ];

      final next = statusOrder
          .skipWhile((s) => s != currentStatus)
          .skip(1)
          .followedBy(statusOrder)
          .firstWhere(
            // CALL SITE CHANGE: Removed the second argument
            (s) => condition(s),
            orElse: () => currentStatus,
          );

      return next;
  }
}