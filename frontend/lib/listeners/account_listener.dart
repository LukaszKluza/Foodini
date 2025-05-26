import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:frontend/config/app_config.dart';
import 'package:frontend/states/account_states.dart';
import 'package:frontend/utils/exception_converter.dart';

import '../config/constants.dart';

class AccountListenerHelper {
  static void accountStateListener(BuildContext context, AccountState state,
      {required bool mounted}) {
    if (state is AccountDeleteSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppConfig.successfullyDeletedAccount)),
      );
      goHome(mounted, context);
    } else if (state is AccountLogoutSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppConfig.successfullyLoggedOut)),
      );
      goHome(mounted, context);
    } else if (state is AccountFailure) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ExceptionConverter.formatErrorMessage(
              state.error.data,
            ),
          ),
        ),
      );
    }
  }

  static void goHome(bool mounted, BuildContext context) {
    Future.delayed(
        const Duration(milliseconds: Constants.redirectionDelay), () {
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          context.go('/');
        });
      }
    });
  }
}
