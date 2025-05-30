import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/l10n/app_localizations.dart';

import 'package:frontend/config/app_config.dart';
import 'package:frontend/utils/user_validators.dart';

Future<BuildContext> pumpAppWithLocalization(WidgetTester tester) async {
  late BuildContext testContext;

  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Builder(
        builder: (context) {
          testContext = context;
          return Container();
        },
      ),
    ),
  );

  return testContext;
}

void main() {
  group('Validation Tests', () {
    // Test validateCountry
    testWidgets(
      'validateCountry returns error message when selectedCountry is null or empty',
      (tester) async {
        final context = await pumpAppWithLocalization(tester);

        expect(validateCountry(null, context), equals('Select your country'));
        expect(validateCountry('', context), equals('Select your country'));
      },
    );

    testWidgets(
      'validateCountry returns null when selectedCountry is not null or empty',
      (tester) async {
        final context = await pumpAppWithLocalization(tester);

        expect(validateCountry('USA', context), isNull);
      },
    );

    // Test validateName
    testWidgets(
      'validateName returns error message when value is null or empty',
      (tester) async {
        final context = await pumpAppWithLocalization(tester);

        expect(validateName(null, context), equals('Name is required'));
        expect(validateName('', context), equals('Name is required'));
      },
    );

    testWidgets(
      'validateName returns error message for name length or invalid characters',
      (tester) async {
        final context = await pumpAppWithLocalization(tester);

        expect(
          validateName('A', context),
          equals('Provide correct name'),
        ); // Too short
        expect(
          validateName('A very long name that exceeds the limit', context),
          equals('Provide correct name'),
        ); // Too long
        expect(
          validateName('John123', context),
          equals('Provide correct name'),
        ); // Invalid characters
      },
    );

    testWidgets('validateName returns null when value is valid', (
      tester,
    ) async {
      final context = await pumpAppWithLocalization(tester);

      expect(validateName('John', context), isNull);
    });

    // Test validateEmail
    testWidgets(
      'validateEmail returns error message when value is null or empty',
      (tester) async {
        final context = await pumpAppWithLocalization(tester);

        expect(validateEmail(null, context), equals('E-mail is required'));
        expect(validateEmail('', context), equals('E-mail is required'));
      },
    );

    testWidgets(
      'validateEmail returns error message for invalid email format',
      (tester) async {
        final context = await pumpAppWithLocalization(tester);

        expect(
          validateEmail('invalidEmail', context),
          equals("Enter valid e-mail"),
        );
        expect(
          validateEmail('invalid@com', context),
          equals("Enter valid e-mail"),
        );
      },
    );

    testWidgets('validateEmail returns null when email is valid', (
      tester,
    ) async {
      final context = await pumpAppWithLocalization(tester);

      expect(validateEmail('test@example.com', context), isNull);
    });

    // Test validatePassword
    testWidgets(
      'validatePassword returns error message when value is null or empty',
      (tester) async {
        final context = await pumpAppWithLocalization(tester);

        expect(
          validatePassword(null, context),
          equals('Password is required'),
        );
        expect(
          validatePassword('', context),
          equals('Password is required'),
        );
      },
    );

    testWidgets('validatePassword returns error message for short password', (
      tester,
    ) async {
      final context = await pumpAppWithLocalization(tester);

      expect(
        validatePassword('12345', context),
        equals('Password length must be between'),
      );
    });

    testWidgets('validatePassword returns error message for long password', (
      tester,
    ) async {
      final context = await pumpAppWithLocalization(tester);

      expect(
        validatePassword('a' * 70, context),
        equals('Password length must be between'),
      );
    });

    testWidgets(
      'validatePassword returns error message for invalid complexity',
      (tester) async {
        final context = await pumpAppWithLocalization(tester);

        expect(
          validatePassword('password', context),
          equals(
            'Password must contain letters (capital and lowercase) and numbers',
          ),
        );
      },
    );

    testWidgets('validatePassword returns null when password is valid', (
      tester,
    ) async {
      final context = await pumpAppWithLocalization(tester);

      expect(validatePassword('Password123', context), isNull);
    });

    // Test validateConfirmPassword
    testWidgets(
      'validateConfirmPassword returns error message when value is null or empty',
      (tester) async {
        final context = await pumpAppWithLocalization(tester);

        expect(
          validateConfirmPassword(null, 'Password123', context),
          equals('Password confirmation is required'),
        );
        expect(
          validateConfirmPassword('', 'Password123', context),
          equals('Password confirmation is required'),
        );
      },
    );

    testWidgets(
      'validateConfirmPassword returns error message when passwords do not match',
      (tester) async {
        final context = await pumpAppWithLocalization(tester);

        expect(
          validateConfirmPassword('DifferentPassword', 'Password123', context),
          equals('Passwords must be the same'),
        );
      },
    );

    testWidgets('validateConfirmPassword returns null when passwords match', (
      tester,
    ) async {
      final context = await pumpAppWithLocalization(tester);

      expect(
        validateConfirmPassword('Password123', 'Password123', context),
        isNull,
      );
    });
  });
}
