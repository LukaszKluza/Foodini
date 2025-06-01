import 'package:flutter/material.dart';

class CaloriesPredictionListenerHelper {
  static void handle({
    required BuildContext context,
    required dynamic state,
    String? successMessage,
    String Function(BuildContext)? successMessageBuilder,
  }) {
    final messenger = ScaffoldMessenger.of(context);

    if (state.isSuccess == true) {
      final message = successMessageBuilder != null
          ? successMessageBuilder(context)
          : successMessage ?? 'Operation completed successfully';

      messenger.showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );
    } else if (state.errorMessage != null) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(state.errorMessage!),
        ),
      );
    }
  }
}
