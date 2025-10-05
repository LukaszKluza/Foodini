class MealRecipeStep {
  final String description;
  final bool optional;

  MealRecipeStep({
    required this.description,
    required this.optional,
  });

  Map<String, dynamic> toJson() => {
    'description': description,
    'optional': optional,
  };

  factory MealRecipeStep.fromJson(Map<String, dynamic> json) {
    return MealRecipeStep(
      description: json['description'],
      optional: json['optional'] as bool,
    );
  }
}
