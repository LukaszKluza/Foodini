import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/config/constants.dart';
import 'package:frontend/foodini.dart';
import 'package:frontend/l10n/app_localizations.dart';
import 'package:frontend/states/account_states.dart';
import 'package:frontend/utils/exception_converter.dart';
import 'package:go_router/go_router.dart';

class AccountListenerHelper {
  static void accountStateListener(
    BuildContext context,
    AccountState state, {
    required bool mounted,
  }) {
    if (state is AccountDeleteSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.successfullyDeletedAccount,
          ),
        ),
      );
      goHome(mounted, context);
    } else if (state is AccountLogoutSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.successfullyLoggedOut),
        ),
      );
      goHome(mounted, context);
    } else if (state is AccountChangeLanguageSuccess) {
      var newLanguage = state.language;
      context.read<LanguageCubit>().change(newLanguage);
    } else if (state is AccountFailure) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ExceptionConverter.formatErrorMessage(state.error.data, context),
          ),
        ),
      );
    }
  }

  static void goHome(bool mounted, BuildContext context) {
    final router = GoRouter.of(context);

    Future.delayed(
      const Duration(milliseconds: Constants.redirectionDelay),
      () {
        if (mounted) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            router.go('/');
          });
        }
      },
    );
  }
}
