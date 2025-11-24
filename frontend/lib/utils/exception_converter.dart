import 'package:flutter/cupertino.dart';
import 'package:frontend/api_exception.dart';
import 'package:frontend/l10n/app_localizations.dart';
import 'package:frontend/states/register_states.dart';

class ExceptionConverter extends RegisterState {
  static String formatErrorMessage(dynamic error, BuildContext context) {
    if (error == null || (error is ApiException && error.data == null)) return AppLocalizations.of(context)!.unknownError;

    if (error is ApiException && (error.statusCode ?? 0) >= 500) {
      return AppLocalizations.of(context)!.unknownError;
    }

    if (error is String) return error;

    if (error is List) {
      return error.map((e) => formatErrorMessage(e, context)).join('\n');
    }

    if (error is Map) {
      final detail = error['detail'];
      if (detail != null) {
        return formatErrorMessage(detail, context);
      }

      return error.entries
          .map((e) => '${e.key}: ${formatErrorMessage(e.value, context)}')
          .join('\n');
    }

    return error.toString();
  }
}
