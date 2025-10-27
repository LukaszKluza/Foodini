import 'package:flutter/material.dart';
import 'package:frontend/config/constants.dart';
import 'package:frontend/config/styles.dart';
import 'package:frontend/l10n/app_localizations.dart';
import 'package:frontend/states/change_password_states.dart';
import 'package:frontend/utils/exception_converter.dart';
import 'package:go_router/go_router.dart';

class ChangePasswordListenerHelper {
  static void onChangePasswordListener({
    required BuildContext context,
    required ChangePasswordState state,
    required bool mounted,
    required void Function(String) setMessage,
    required void Function(TextStyle) setMessageStyle,
  }) {
    if (state is ChangePasswordSuccess) {
      setMessage(AppLocalizations.of(context)!.passwordSuccessfullyChanged);
      setMessageStyle(Styles.successStyle);
      Future.delayed(
        const Duration(milliseconds: Constants.redirectionDelay),
        () {
          if (mounted) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.go('/main-page');
            });
          }
        },
      );
    } else if (state is ChangePasswordFailure) {
      setMessage(
        ExceptionConverter.formatErrorMessage(state.error.data, context),
      );
    }
  }
}
