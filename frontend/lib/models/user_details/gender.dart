enum Gender {
  male(0, 'male'),
  female(1, 'female');

  final int value;
  final String nameStr;

  const Gender(this.value, this.nameStr);

  static Gender fromJson(String value) {
    switch (value.toUpperCase()) {
      case 'male':
        return Gender.male;
      case 'female':
        return Gender.female;
      default:
        throw ArgumentError('Unknown gender: $value');
    }
  }

  String toJson() => nameStr;

  static Gender? fromInt(int value) {
    return Gender.values.firstWhere(
      (e) => e.value == value,
      orElse: () => throw ArgumentError('Invalid gender value: $value'),
    );
  }

  int toInt() => value;
}
