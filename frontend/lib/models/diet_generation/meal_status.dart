import 'package:frontend/models/diet_generation/meal.dart';
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

  static MealStatus getNextStatus(
      MealType currentType,
      Map<MealType, Meal> allMeals,
  ) {
      final currentStatus = allMeals[currentType]!.status;
      final statusCycle = [MealStatus.toEat, MealStatus.eaten, MealStatus.skipped];
      int currentIndex = statusCycle.indexOf(currentStatus);

      if (currentStatus == MealStatus.pending) {
          currentIndex = 0;
      }

      int nextIndex = (currentIndex + 1) % statusCycle.length;

      return statusCycle[nextIndex];
  }
}