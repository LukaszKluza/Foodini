import 'package:frontend/utils/query_parameters_mapper.dart';
import 'package:test/test.dart';

void main() {
  group('QueryParametersMapper', () {
    test('Test with multiple query parameters', () {
      final result = QueryParametersMapper.parseQueryParams(
        'status=success&user=admin&role=admin',
      );
      expect(result, {'status': 'success', 'user': 'admin', 'role': 'admin'});
    });

    test('Test with a single query parameter', () {
      final result = QueryParametersMapper.parseQueryParams('status=success');
      expect(result, {'status': 'success'});
    });

    test('Test with an empty query string', () {
      final result = QueryParametersMapper.parseQueryParams('');
      expect(result, {});
    });

    test('Test with malformed parameter without an equals sign', () {
      final result = QueryParametersMapper.parseQueryParams(
        'status&user=admin',
      );
      expect(result, {'user': 'admin'});
    });

    test('Test with multiple equals signs in one parameter', () {
      final result = QueryParametersMapper.parseQueryParams(
        'status=success&user=admin=admin',
      );
      expect(result, {'status': 'success', 'user': 'admin'});
    });
  });
}
