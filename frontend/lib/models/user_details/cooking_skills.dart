enum CookingSkills {
  beginner(0, 'beginner'),
  advanced(1, 'advanced'),
  professional(2, 'professional');

  final int value;
  final String nameStr;

  const CookingSkills(this.value, this.nameStr);

  String toJson() => nameStr;

  static CookingSkills fromJson(String value) {
    return CookingSkills.values.firstWhere(
          (e) => e.nameStr == value,
      orElse: () => throw ArgumentError('Unknown cooking skill: $value'),
    );
  }

  int toInt() => value;

  static CookingSkills fromInt(int value) {
    return CookingSkills.values.firstWhere(
          (e) => e.value == value,
      orElse: () => throw ArgumentError('Invalid cooking skill value: $value'),
    );
  }
}
