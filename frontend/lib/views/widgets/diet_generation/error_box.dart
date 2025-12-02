import 'package:flutter/material.dart';

Padding buildErrorBox(BuildContext context, String label, {Widget? button}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 26.0, vertical: 36.0),
    child: Center(
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
            if (button != null) ...[
              const SizedBox(height: 12),
              Row(children: [button]),
            ],
          ],
        ),
      ),
    ),
  );
}
