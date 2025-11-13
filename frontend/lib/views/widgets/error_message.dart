import 'package:flutter/material.dart';

class ErrorMessage extends StatelessWidget {
  final String message;
  final EdgeInsetsGeometry padding;
  final int maxLines;
  final bool centerText;

  const ErrorMessage({
    super.key,
    required this.message,
    this.padding = const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
    this.maxLines = 3,
    this.centerText = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          border: Border.all(color: Colors.red.shade300),
          borderRadius: BorderRadius.circular(8.0),
          boxShadow: [
            BoxShadow(
              color: Colors.red.withValues(),
              offset: const Offset(0, 2),
              blurRadius: 4.0,
            ),
          ],
        ),
        child: Text(
          message,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.red,
            fontWeight: FontWeight.w500,
          ),
          textAlign: centerText ? TextAlign.center : TextAlign.start,
          softWrap: true,
          maxLines: maxLines,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
