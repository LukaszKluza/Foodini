import 'package:flutter/material.dart';

Widget rectangularButton(
  String text,
  IconData icon,
  double width,
  double height,
  VoidCallback? onPressed,
) {
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
