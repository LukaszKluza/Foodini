import 'package:flutter/material.dart';
import 'package:frontend/config/app_config.dart';
import 'package:frontend/config/styles.dart';
import 'package:frontend/states/provide_email_states.dart';
import 'package:frontend/utils/exception_converter.dart';

class ProvideEmailListenerHelper {
  static void onProvideEmailListener({
    required BuildContext context,
    required ProvideEmailState state,
    required void Function(void Function()) setState,
    required bool mounted,
    required void Function(String) setMessage,
    required void Function(TextStyle) setMessageStyle,
  }) {
    if (state is ProvideEmailSuccess) {
      setState(() {
        setMessage(AppConfig.checkEmailAddressToSetNewPassword);
        setMessageStyle(Styles.successStyle);
      });
    } else if (state is ProvideEmailFailure) {
      setState(() {
        setMessage(ExceptionConverter.formatErrorMessage(
          state.error.data, context
        ));
      });
    }
  }
}

