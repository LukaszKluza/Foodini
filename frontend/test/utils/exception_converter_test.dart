import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/utils/exception_converter.dart';

Future<void> runWithContext(
  WidgetTester tester,
  void Function(BuildContext) body,
) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Builder(
        builder: (context) {
          body(context);
          return Container();
        },
      ),
    ),
  );
}

void main() {
  group('ExceptionConverter.formatErrorMessage', () {
    testWidgets('should return the same string if error is a string', (
      tester,
    ) async {
      final input = 'Simple error';

      await runWithContext(tester, (context) {
        final result = ExceptionConverter.formatErrorMessage(input, context);
        expect(result, equals(input));
      });
    });

    testWidgets('should flatten a map with a "detail" key containing a list', (
      tester,
    ) async {
      final input = {
        'detail': [
          'error one',
          {'sub_error': 'error two'},
        ],
      };

      await runWithContext(tester, (context) {
        final result = ExceptionConverter.formatErrorMessage(input, context);
        expect(result, equals('error one\nsub_error: error two'));
      });
    });

    testWidgets('should recursively format a map without a "detail" key', (
      tester,
    ) async {
      final input = {
        'field1': 'error1',
        'field2': {'nestedField': 'nestedError'},
      };

      await runWithContext(tester, (context) {
        final result = ExceptionConverter.formatErrorMessage(input, context);
        expect(
          result,
          equals('field1: error1\nfield2: nestedField: nestedError'),
        );
      });
    });

    testWidgets('should format a list of errors', (tester) async {
      final input = ['error1', 'error2', 'error3'];

      await runWithContext(tester, (context) {
        final result = ExceptionConverter.formatErrorMessage(input, context);
        expect(result, equals('error1\nerror2\nerror3'));
      });
    });

    testWidgets('should call toString on other error types', (tester) async {
      final input = Exception('some exception');

      await runWithContext(tester, (context) {
        final result = ExceptionConverter.formatErrorMessage(input, context);
        expect(result, equals(input.toString()));
      });
    });
  });
}
