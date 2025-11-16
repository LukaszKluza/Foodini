import 'package:flutter/material.dart';
import 'package:frontend/l10n/app_localizations.dart';
import 'package:frontend/views/widgets/action_button.dart';

class DietGenerationInfoButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isRegenerateMode;
  final DateTime selectedDay;
  final String? label;

  const DietGenerationInfoButton({
    super.key,
    this.onPressed,
    required this.selectedDay,
    this.label,
    this.isRegenerateMode = true,
  });

  @override
  Widget build(BuildContext context) {
    final buttonLabel = label ?? AppLocalizations.of(context)!.generateNewPlan;
    final String keyId = isRegenerateMode ? 'regenerate_meals_button' : 'generate_new_button';
    final Color color = isRegenerateMode ? const Color(0xFFF09090) : const Color(0xFF3B9B49);

    return Positioned(
      left: 16,
      right: 16,
      bottom: 8,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ActionButton(
            onPressed: onPressed,
            color: color,
            label: buttonLabel,
            keyId: keyId,
          ),
        ],
      ),
    );
  }
}