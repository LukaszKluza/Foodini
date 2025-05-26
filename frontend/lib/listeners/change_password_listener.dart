import 'package:flutter/material.dart';
import 'package:frontend/config/app_config.dart';
import 'package:frontend/config/styles.dart';
import 'package:frontend/states/change_password_states.dart';
import 'package:frontend/utils/exception_converter.dart';
import 'package:go_router/go_router.dart';

import '../config/constants.dart';


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
        setMessage(AppConfig.passwordSuccessfullyChanged);
        setMessageStyle(Styles.successStyle);
      });
      Future.delayed(const Duration(milliseconds: Constants.redirectionDelay), () {
        if (mounted) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.go('/main_page');
          });
        }
      });
    } else if (state is ChangePasswordFailure) {
      setState(() {
        setMessage(ExceptionConverter.formatErrorMessage(
          state.error.data,
        ));
      });
    }
  }
}

