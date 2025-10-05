class Ingredient {
  final double volume;
  final String unit;
  final String name;
  final String? optionalNote;

  Ingredient({
    required this.volume,
    required this.unit,
    required this.name,
    this.optionalNote,
  });

  Map<String, dynamic> toJson() => {
    'volume': volume,
    'unit': unit,
    'name': name,
    'optional_note': optionalNote,
  };

  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
      volume: json['volume'] as double,
      unit: json['unit'],
      name: json['name'],
      optionalNote: json['optional_note'],
    );
  }
}