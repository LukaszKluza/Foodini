import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/blocs/user_details/macros_change_bloc.dart';
import 'package:frontend/config/constants.dart';
import 'package:frontend/config/styles.dart';
import 'package:frontend/events/user_details/macros_change_events.dart';
import 'package:frontend/l10n/app_localizations.dart';
import 'package:frontend/states/macros_change_states.dart';
import 'package:frontend/utils/exception_converter.dart';
import 'package:go_router/go_router.dart';

class MacrosChangeListenerHelper {
  static void onMacrosChangeSubmitListener({
    required BuildContext context,
    required MacrosChangeState state,
    required void Function(void Function()) setState,
    required bool mounted,
    required void Function(String) setMessage,
    required void Function(TextStyle) setMessageStyle,
  }) {
    if (state is MacrosChangeSubmitSuccess) {
      final bloc = context.read<MacrosChangeBloc>();

      setState(() {
        setMessage(AppLocalizations.of(context)!.formSuccessfullySubmitted);
        setMessageStyle(Styles.successStyle);
      });

      Future.delayed(
        const Duration(milliseconds: Constants.redirectionDelay),
        () {
          if (mounted) {
            bloc.add(MacrosChangeResetRequested());
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.go('/main-page');
            });
          }
        },
      );
    } else if (state is MacrosChangeSubmitFailure) {
      String message = AppLocalizations.of(context)!.unknownError;
      if (state.error != null) {
        message = ExceptionConverter.formatErrorMessage(
          state.error?.data,
          context,
        );
      } else if (state.getMessage != null) {
        message = state.getMessage!(context);
      }
      setState(() {
        setMessage(message);
      });

      if (mounted) {
        context.read<MacrosChangeBloc>().add(MacrosChangeResetRequested());
      }
    }
  }
}
