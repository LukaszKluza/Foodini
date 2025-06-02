class AdvancedBodyParameters {
  late double? musclePercentage;
  late double? waterPercentage;
  late double? fatPercentage;

  AdvancedBodyParameters({
    required this.musclePercentage,
    required this.waterPercentage,
    required this.fatPercentage,
  });

  Map<String, dynamic> toJson() => {
    'muscle_percentage': musclePercentage,
    'water_percentage': waterPercentage,
    'fat_percentage': fatPercentage,
  };
}
