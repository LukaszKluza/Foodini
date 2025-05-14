import 'package:flutter/material.dart';
import 'package:frontend/config/app_config.dart';
import 'package:frontend/states/change_password_sates.dart';
import 'package:frontend/utils/exception_converter.dart';
import 'package:go_router/go_router.dart';

class ChangePasswordListenerHelper {
  static void onChangePasswordListener({
    required BuildContext context,
    required ChangePasswordState state,
    required void Function(void Function()) setState,
    required bool mounted,
    required void Function(String) setMessage,
    required void Function(TextStyle) setMessageStyle,
  }) {
    if (state is ChangePasswordSuccess) {
      setState(() {
        setMessage(AppConfig.checkAndConfirmEmailAddress);
        setMessageStyle(AppConfig.successStyle);
      });
      Future.delayed(const Duration(milliseconds: AppConfig.redirectionDelay), () {
        if (mounted) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.go('/account');
          });
        }
      });
    } else if (state is ChangePasswordFailure) {
      setState(() {
        setMessage(ExceptionConverter.formatErrorMessage(
          state.error.data["detail"],
        ));
      });
    }
  }
}

