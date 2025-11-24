import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/blocs/diet_generation/daily_summary_bloc.dart';
import 'package:frontend/blocs/user_details/macros_change_bloc.dart';
import 'package:frontend/config/constants.dart';
import 'package:frontend/events/diet_generation/daily_summary_events.dart';
import 'package:frontend/events/user_details/macros_change_events.dart';
import 'package:frontend/foodini.dart';
import 'package:frontend/l10n/app_localizations.dart';
import 'package:frontend/states/account_states.dart';
import 'package:frontend/utils/cache_manager.dart';
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
      context.read<MacrosChangeBloc>().add(ResetMacrosChangeBloc());
      context.read<DailySummaryBloc>().add(ResetDailySummary());
      unawaited(context.read<CacheManager>().clearAllCache());
      goHome(mounted, context);
    } else if (state is AccountLogoutSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.successfullyLoggedOut),
        ),
      );
      context.read<MacrosChangeBloc>().add(ResetMacrosChangeBloc());
      context.read<DailySummaryBloc>().add(ResetDailySummary());
      unawaited(context.read<CacheManager>().clearAllCache());
      goHome(mounted, context);
    } else if (state is AccountChangeLanguageSuccess) {
      var newLanguage = state.language;
      context.read<LanguageCubit>().change(newLanguage);
      unawaited(context.read<CacheManager>().clearAllCache());
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
