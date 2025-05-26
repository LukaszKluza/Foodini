import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/config/app_config.dart';
import 'package:frontend/config/constants.dart';
import 'package:frontend/config/styles.dart';
import 'package:frontend/utils/exception_converter.dart';
import 'package:frontend/states/register_states.dart';

class RegisterListenerHelper {
  static void onChangePasswordListener({
    required BuildContext context,
    required RegisterState state,
    required void Function(void Function()) setState,
    required bool mounted,
    required void Function(String) setMessage,
    required void Function(TextStyle) setMessageStyle,
  }) {
    if (state is RegisterSuccess) {
      setState(() {
        setMessage(AppConfig.checkAndConfirmEmailAddress);
        setMessageStyle(Styles.successStyle);
      });
      Future.delayed(
        const Duration(milliseconds: Constants.redirectionDelay),
        () {
          if (mounted) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.go('/login');
            });
          }
        },
      );
    } else if (state is RegisterFailure) {
      setState(() {
        setMessage(
          ExceptionConverter.formatErrorMessage(state.error.data["detail"]),
        );
      });
    }
  }
}
