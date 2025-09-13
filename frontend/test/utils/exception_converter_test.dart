import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/utils/exception_converter.dart';

void main() {
  group('ExceptionConverter.formatErrorMessage', () {
    test('should return the same string if error is a string', () {
      final input = "Simple error";
      final result = ExceptionConverter.formatErrorMessage(input);
      expect(result, equals(input));
    });

    test('should flatten a map with a "detail" key containing a list', () {
      final input = {
        'detail': [
          'error one',
          {'sub_error': 'error two'}
        ]
      };
      final result = ExceptionConverter.formatErrorMessage(input);
      expect(result, equals('error one\nsub_error: error two'));
    });

    test('should recursively format a map without a "detail" key', () {
      final input = {
        'field1': 'error1',
        'field2': {'nestedField': 'nestedError'}
      };
      final result = ExceptionConverter.formatErrorMessage(input);
      expect(result, equals('field1: error1\nfield2: nestedField: nestedError'));
    });

    test('should format a list of errors', () {
      final input = ['error1', 'error2', 'error3'];
      final result = ExceptionConverter.formatErrorMessage(input);
      expect(result, equals('error1\nerror2\nerror3'));
    });

    test('should call toString on other error types', () {
      final input = Exception('some exception');
      final result = ExceptionConverter.formatErrorMessage(input);
      expect(result, equals(input.toString()));
    });
  });
}
