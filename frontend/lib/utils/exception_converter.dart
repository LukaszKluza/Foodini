import 'package:frontend/states/register_states.dart';

class ExceptionConverter extends RegisterState {
  static String formatErrorMessage(dynamic error) {
    if (error is String) {
      return error;
    }

    if (error is Map) {
      if (error.containsKey('detail')) {
        final detail = error['detail'];

        if (detail is List) {
          return detail.map((e) => formatErrorMessage(e)).join('\n');
        } else {
          return formatErrorMessage(detail);
        }
      }

      return error.entries
          .map((e) => '${e.key}: ${formatErrorMessage(e.value)}')
          .join('\n');
    }

    if (error is List) {
      return error.map((e) => formatErrorMessage(e)).join('\n');
    }

    return error.toString();
  }
}
