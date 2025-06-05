enum
Language {
  pl('PL', 'Polski', '🇵🇱'),
  en('EN', 'English', '🇬🇧');

  final String code;
  final String name;
  final String flag;

  const Language(this.code, this.name, this.flag);

  static Language fromJson(String value) {
    switch (value.toUpperCase()) {
      case 'PL':
        return Language.pl;
      case 'EN':
        return Language.en;
      default:
        throw ArgumentError('Unknown language: $value');
    }
  }

  String toJson() => code;
}
