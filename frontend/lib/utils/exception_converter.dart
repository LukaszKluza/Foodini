import 'package:frontend/config/app_config.dart';
import 'package:frontend/states/register_states.dart';

class ExceptionConverter extends RegisterState {
  static String formatErrorMessage(dynamic error) {
    if (error == null) return AppConfig.unknownError;

    if (error is String) return error;

    if (error is List) {
      return error.map(formatErrorMessage).join('\n');
    }

    if (error is Map) {
      final detail = error['detail'];
      if (detail != null) {
        return formatErrorMessage(detail);
      }

      return error.entries
          .map((e) => '${e.key}: ${formatErrorMessage(e.value)}')
          .join('\n');
    }

    return error.toString();
  }
}
