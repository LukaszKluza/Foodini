import 'package:flutter/material.dart';

Widget circleButton(BuildContext context,
    {required IconData icon, VoidCallback? onTap, double iconSize = 46}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: onTap != null
            ? Colors.white.withAlpha(66)
            : Colors.white.withAlpha(30),
        border: Border.all(
          color: Colors.white.withAlpha(onTap != null ? 90 : 38),
        ),
      ),
      child: Icon(
        icon,
        color: onTap != null ? Colors.orangeAccent : Colors.grey,
        size: iconSize,
      ),
    ),
  );
}