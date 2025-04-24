import 'package:test/test.dart';
import 'package:frontend/config/app_config.dart';
import 'package:frontend/utils/userValidators.dart';

void main() {
  group('Validation Tests', () {
    
    // Test validateAge
    test('validateAge returns error message when value is null', () {
      expect(validateAge(null), equals(AppConfig.requiredAge));
    });

    test('validateAge returns null when value is not null', () {
      expect(validateAge(25), isNull);
    });
    
    // Test validateCountry
    test('validateCountry returns error message when selectedCountry is null or empty', () {
      expect(validateCountry('Country', null), equals(AppConfig.requiredCountry));
      expect(validateCountry('Country', ''), equals(AppConfig.requiredCountry));
    });

    test('validateCountry returns null when selectedCountry is not null or empty', () {
      expect(validateCountry('Country', 'USA'), isNull);
    });

    // Test validateName
    test('validateName returns error message when value is null or empty', () {
      expect(validateName(null), equals(AppConfig.requiredName));
      expect(validateName(''), equals(AppConfig.requiredName));
    });

    test('validateName returns error message for name length or invalid characters', () {
      expect(validateName('A'), equals(AppConfig.provideCorrectName)); // Too short
      expect(validateName('A very long name that exceeds the limit'), equals(AppConfig.provideCorrectName)); // Too long
      expect(validateName('John123'), equals(AppConfig.provideCorrectName)); // Invalid characters
    });

    test('validateName returns null when value is valid', () {
      expect(validateName('John'), isNull);
    });

    // Test validateEmail
    test('validateEmail returns error message when value is null or empty', () {
      expect(validateEmail(null), equals(AppConfig.requiredEmail));
      expect(validateEmail(''), equals(AppConfig.requiredEmail));
    });

    test('validateEmail returns error message for invalid email format', () {
      expect(validateEmail('invalidEmail'), equals(AppConfig.invalidEmail));
      expect(validateEmail('invalid@com'), equals(AppConfig.invalidEmail));
    });

    test('validateEmail returns null when email is valid', () {
      expect(validateEmail('test@example.com'), isNull);
    });

    // Test validatePassword
    test('validatePassword returns error message when value is null or empty', () {
      expect(validatePassword(null), equals(AppConfig.requiredPassword));
      expect(validatePassword(''), equals(AppConfig.requiredPassword));
    });

    test('validatePassword returns error message for short password', () {
      expect(validatePassword('12345'), equals(AppConfig.minimalPasswordLength));
    });

    test('validatePassword returns error message for long password', () {
      expect(validatePassword('a' * 70), equals(AppConfig.maximalPasswordLength));
    });

    test('validatePassword returns error message for invalid complexity', () {
      expect(validatePassword('password'), equals(AppConfig.passwordComplexityError));
    });

    test('validatePassword returns null when password is valid', () {
      expect(validatePassword('Password123'), isNull);
    });

    // Test validateConfirmPassword
    test('validateConfirmPassword returns error message when value is null or empty', () {
      expect(validateConfirmPassword(null, 'Password123'), equals(AppConfig.requiredPasswordConfirmation));
      expect(validateConfirmPassword('', 'Password123'), equals(AppConfig.requiredPasswordConfirmation));
    });

    test('validateConfirmPassword returns error message when passwords do not match', () {
      expect(validateConfirmPassword('DifferentPassword', 'Password123'), equals(AppConfig.samePasswords));
    });

    test('validateConfirmPassword returns null when passwords match', () {
      expect(validateConfirmPassword('Password123', 'Password123'), isNull);
    });
    
  });
}
