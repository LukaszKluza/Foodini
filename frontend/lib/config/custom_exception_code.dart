enum CustomExceptionCode {
  missingDietPredictions('MISSING_DIET_PREDICTIONS');

  final String code;

  const CustomExceptionCode(this.code);

  String toJson() => code;

  static CustomExceptionCode fromJson(String value) {
    return CustomExceptionCode.values.firstWhere(
          (e) => e.code == value,
      orElse: () => throw ArgumentError('Unknown exception code: $value'),
    );
  }
}