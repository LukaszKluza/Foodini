import 'package:flutter/material.dart';

Widget rectangularButton(
  String text,
  IconData icon,
  double screenWidth,
  double screenHeight,
  VoidCallback? onPressed,
) {
  final width = screenWidth * 0.38;
  final height = screenHeight * 0.20;

  return ElevatedButton(
    onPressed: onPressed,
    style: ElevatedButton.styleFrom(
      fixedSize: Size(width, height),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      padding: EdgeInsets.zero,
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: height * 0.3),
        Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: height * 0.12),
        ),
      ],
    ),
  );
}
