import 'package:flutter/material.dart';
import 'package:frontend/config/constants.dart';
import 'package:frontend/config/styles.dart';
import 'package:frontend/l10n/app_localizations.dart';
import 'package:frontend/models/processing_status.dart';
import 'package:frontend/states/macros_change_states.dart';
import 'package:go_router/go_router.dart';

class MacrosChangeListenerHelper {
  static void onMacrosChangeSubmitListener({
    required BuildContext context,
    required MacrosChangeState state,
    required bool mounted,
    required void Function(String) setMessage,
    required void Function(int) setErrorCode,
    required void Function(TextStyle) setMessageStyle,
  }) {
    if (state.processingStatus == ProcessingStatus.submittingSuccess) {
      setMessage(AppLocalizations.of(context)!.formSuccessfullySubmitted);
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
    } else if (state.getMessage != null) {
      setMessage(state.getMessage!(context));
      if (state.errorCode != null) {
        setErrorCode(state.errorCode!);
      }
    }
  }
}
