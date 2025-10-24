class MealItem {
  final String name;
  final int carbs;
  final int fat;
  final int protein;
  final int calories;

  MealItem({
    required this.name,
    required this.carbs,
    required this.fat,
    required this.protein,
    required this.calories,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'carbs': carbs,
    'fat': fat,
    'protein': protein,
    'calories': calories,
  };

  factory MealItem.fromJson(Map<String, dynamic> json) {
    return MealItem(
      name: json['name'] as String,
      carbs: json['carbs'] as int,
      fat: json['fat'] as int,
      protein: json['protein'] as int,
      calories: json['calories'] as int,
    );
  }
}
