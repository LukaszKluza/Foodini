class Ingredient {
  final double volume;
  final String unit;
  final String name;

  Ingredient({
    required this.volume,
    required this.unit,
    required this.name,
  });

  Map<String, dynamic> toJson() => {
    'volume': volume,
    'unit': unit,
    'name': name,
  };

  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
      volume: json['volume'] as double,
      unit: json['unit'],
        name: json['name'],
    );
  }
}