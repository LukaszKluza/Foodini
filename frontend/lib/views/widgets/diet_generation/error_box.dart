import 'package:flutter/material.dart';
import 'package:frontend/views/widgets/diet_generation/action_buttons.dart';

Padding buildErrorBox(BuildContext context, String label,
    {String? buttonText, VoidCallback? onButtonPressed}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 26.0, vertical: 120.0),
    child:
    Center(
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          border: Border.all(color: Color(0xFFD32F2F), width: 2),
          borderRadius: BorderRadius.circular(12),
          color: Color(0xFFFFCDD2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            if (buttonText != null && onButtonPressed != null) ...[
              const SizedBox(height: 12),
              customCenterButton(
                Key('refresh_request_button'),
                onButtonPressed,
                ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF4F4F),
                  minimumSize: const Size.fromHeight(48),
                ),
                Text(
                    buttonText,
                    style: const TextStyle(color: Colors.black54, fontSize: 14, fontWeight: FontWeight.w700)
                ),
              )
            ],
          ],
        )
      ),
    )
  );
}
