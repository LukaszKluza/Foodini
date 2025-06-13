import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/config/constants.dart';
import 'package:frontend/config/styles.dart';
import 'package:frontend/foodini.dart';
import 'package:frontend/states/login_states.dart';
import 'package:frontend/utils/exception_converter.dart';
import 'package:go_router/go_router.dart';

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
        setMessage(state.getMessage!(context));
        setMessageStyle(Styles.successStyle);
      });

      var newLanguage = state.userResponse.language.code;
      context.read<LanguageCubit>().change(Locale(newLanguage.toLowerCase()));

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
        setMessage(state.getMessage!(context));
        setMessageStyle(Styles.successStyle);
      });
    } else if (state is LoginFailure) {
      setState(() {
        setMessage(
          ExceptionConverter.formatErrorMessage(state.error.data, context),
        );
        setMessageStyle(Styles.errorStyle);
      });
    }
  }
}
