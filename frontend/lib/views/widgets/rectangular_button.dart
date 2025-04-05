import 'package:flutter/material.dart';

Widget rectangularButton(String emoji, IconData icon, VoidCallback? onPressed) {
  return ElevatedButton(
    onPressed: onPressed,
    style: ElevatedButton.styleFrom(
      fixedSize: Size(250, 250),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      padding: EdgeInsets.zero,
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 80),
        Text(emoji, style: TextStyle(fontSize: 30)),
      ],
    ),
  );
}
