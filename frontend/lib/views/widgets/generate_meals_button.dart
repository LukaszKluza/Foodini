import 'package:flutter/material.dart';
import 'package:frontend/views/widgets/action_button.dart';

class GenerateMealsButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isRegenerateMode;
  final DateTime selectedDay;

  const GenerateMealsButton({
    super.key,
    required this.onPressed,
    required this.selectedDay,
    this.isRegenerateMode = true,
  });

  @override
  Widget build(BuildContext context) {
    final String label = isRegenerateMode ? 'Regenerate Meals' : 'Generate New Plan';
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
            label: label,
            keyId: keyId,
          ),
        ],
      ),
    );
  }
}