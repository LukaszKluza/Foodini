class Meal {
  final String type;
  final String mealName;
  final String description;
  final String iconUrl;

  Meal({
    required this.type,
    required this.mealName,
    required this.description,
    required this.iconUrl,
  });

  Map<String, dynamic> toJson() => {
    'type': type,
    'meal_name': mealName,
    'description': description,
    'icon_url': iconUrl,
  };

  factory Meal.fromJson(Map<String, dynamic> json) {
    return Meal(
      type: json['type'],
      mealName: json['meal_name'],
      description: json['description'],
      iconUrl: json['icon_url'],
    );
  }
}