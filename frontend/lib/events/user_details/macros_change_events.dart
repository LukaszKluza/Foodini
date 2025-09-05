abstract class MacrosChangeEvent {}

class UpdateProtein extends MacrosChangeEvent {
  final int protein;
  UpdateProtein(this.protein);
}

class UpdateFat extends MacrosChangeEvent {
  final int fat;
  UpdateFat(this.fat);
}

class UpdateCarbs extends MacrosChangeEvent {
  final int carbs;
  UpdateCarbs(this.carbs);
}

class SubmitMacrosChange extends MacrosChangeEvent {}

class MacrosChangeResetRequested extends MacrosChangeEvent {}
