import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/config/constants.dart';
import 'package:frontend/config/styles.dart';
import 'package:frontend/states/login_states.dart';
import 'package:frontend/utils/exception_converter.dart';

class LoginListenerHelper {
  static void onLoginListener({
    required BuildContext context,
    required LoginState state,
    required void Function(void Function()) setState,
    required bool mounted,
    required void Function(String) setMessage,
    required void Function(TextStyle) setMessageStyle,
  }) {
    if (state is LoginSuccess) {
      setState(() {
        setMessage(state.message!);
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
    } else if (state is AccountSuccessVerification ||
        state is ResendAccountVerificationSuccess) {
      setState(() {
        setMessage(state.message!);
        setMessageStyle(Styles.successStyle);
      });
    } else if (state is LoginFailure) {
      setState(() {
        setMessage(ExceptionConverter.formatErrorMessage(state.error.data));
        setMessageStyle(Styles.errorStyle);
      });
    }
  }
}
