import 'package:flutter/material.dart';
import 'package:frontend/config/constants.dart';
import 'package:frontend/config/styles.dart';
import 'package:frontend/states/diet_form_states.dart';
import 'package:frontend/utils/exception_converter.dart';
import 'package:frontend/l10n/app_localizations.dart';

import 'package:go_router/go_router.dart';

class DietFormListenerHelper {
  static void onDietFormSubmitListener({
    required BuildContext context,
    required DietFormState state,
    required void Function(void Function()) setState,
    required bool mounted,
    required void Function(String) setMessage,
    required void Function(TextStyle) setMessageStyle,
  }) {
    if (state is DietFormSubmitSuccess) {
      setState(() {
        setMessage(AppLocalizations.of(context)!.passwordSuccessfullyChanged);
        setMessageStyle(Styles.successStyle);
      });
      Future.delayed(
        const Duration(milliseconds: Constants.redirectionDelay),
        () {
          if (mounted) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.go('/main_page');
            });
          }
        },
      );
    } else if (state is DietFormSubmitFailure) {
      setState(() {
        setMessage(
          ExceptionConverter.formatErrorMessage(state.error.data, context),
        );
      });
    }
  }
}
