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

    print(all);

    bool noEatenFutureMeal(){
      for (int i = all.length - 1; i >= 0; --i) {
        if (all[i].mealStatus == MealStatus.eaten) {
          return false;
        }
        if (all[i].type == currentMeal.type) {
          return true;
        }
      }
      return false;
    }

    bool noPendingFutureMeal(){
      for (int i = all.length - 1; i >= 0; --i) {
        if (all[i].mealStatus == MealStatus.pending) {
          return false;
        }
        if (all[i].type == currentMeal.type) {
          return true;
        }
      }
      return true;
    }

    bool noPendingPreviousMeal(){
      for (int i = 0; i < all.length; ++i) {
        if (all[i].type == currentMeal.type) {
          return true;
        }
        if (all[i].mealStatus == MealStatus.pending) {
          return false;
        }
      }
      return true;
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

    var next = current;

    int index = order.indexOf(current);
    for (int i = 1; i <= order.length; i++) {
      final nextIndex = (index + i) % order.length;
      final nextStatus = order[nextIndex];
      if (condition(nextStatus, current)) {
        next = nextStatus;
        break;
      }
    }

    int getId(){
      for (int i = 0; i < all.length; ++i) {
        if (all[i].type == currentMeal.type) {
          return i;
        }
      }
      return -1;
    }

    if (current == MealStatus.pending){
      for (int i = getId()+1; i < all.length; ++i) {
        if (all[i].mealStatus == MealStatus.toEat) {
          all[i].mealStatus = MealStatus.pending;
          break;
        }
      }
    }

    if (next == MealStatus.pending){
      for (int i = getId()+1; i < all.length; ++i) {
        if (all[i].mealStatus == MealStatus.pending) {
          all[i].mealStatus = MealStatus.toEat;
          break;
        }
      }
    }

    return next;
  }
}