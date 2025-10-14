import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/blocs/user_details/diet_form_bloc.dart';
import 'package:frontend/blocs/user_details/macros_change_bloc.dart';
import 'package:frontend/config/constants.dart';
import 'package:frontend/config/styles.dart';
import 'package:frontend/events/user_details/diet_form_events.dart';
import 'package:frontend/events/user_details/macros_change_events.dart';
import 'package:frontend/l10n/app_localizations.dart';
import 'package:frontend/states/diet_form_states.dart';
import 'package:frontend/utils/exception_converter.dart';
import 'package:go_router/go_router.dart';

class DietFormListenerHelper {
  static void onDietFormSubmitListener({
    required BuildContext context,
    required DietFormState state,
    required bool mounted,
    required void Function(String) setMessage,
    required void Function(TextStyle) setMessageStyle,
  }) {
    if (state is DietFormSubmitSuccess) {
      final dietFormBloc = context.read<DietFormBloc>();
      final macrosChangeBloc = context.read<MacrosChangeBloc>();

      setMessage(AppLocalizations.of(context)!.formSuccessfullySubmitted);
      setMessageStyle(Styles.successStyle);

      macrosChangeBloc.add(SetPredictedCalories(state.predictedCalories));

      Future.delayed(
        const Duration(milliseconds: Constants.redirectionDelay),
        () {
          if (mounted) {
            dietFormBloc.add(DietFormResetRequested());
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.go('/calories-result', extra: state.predictedCalories);
            });
          }
        },
      );
    } else if (state is DietFormSubmitFailure) {
      final bloc = context.read<DietFormBloc>();

      bloc.add(RestoreDietFormStateAfterFailure(state.previousData));

      String message = AppLocalizations.of(context)!.unknownError;
      if (state.error != null) {
        message = ExceptionConverter.formatErrorMessage(
          state.error?.data,
          context,
        );
      } else if (state.getMessage != null) {
        message = state.getMessage!(context);
      }
      setMessage(message);

      if (mounted) {
        context.read<DietFormBloc>().add(DietFormResetRequested());
      }
    }
  }
}
