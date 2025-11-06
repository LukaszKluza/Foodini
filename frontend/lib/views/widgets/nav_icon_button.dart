import 'package:flutter/material.dart';

class NavIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final bool isActive;

  const NavIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.isActive = true,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon),
      color: isActive ? Colors.blue : Colors.grey,
      iconSize: 24,
      onPressed: isActive ? onPressed : null,
    );
  }
}
