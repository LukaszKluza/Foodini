import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:frontend/views/widgets/circle_button.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class BottomNavBarDate extends StatelessWidget {
  final String prevRoute;
  final String nextRoute;
  final DateTime selectedDate;

  const BottomNavBarDate({
    super.key,
    required this.prevRoute,
    required this.nextRoute,
    required this.selectedDate,
  });

  @override
  Widget build(BuildContext context) {
    final prevDate = selectedDate.subtract(const Duration(days: 1));
    final nextDate = selectedDate.add(const Duration(days: 1));

    final prevLabel = DateFormat('dd.MM.yyyy').format(prevDate);
    final nextLabel = DateFormat('dd.MM.yyyy').format(nextDate);

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(72),
            border: Border.all(color: Colors.white.withAlpha(78)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(30),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              circleButton(
                context,
                icon: Icons.arrow_back,
                onTap: () => context.go(prevRoute),
              ),
              _dateButton(label: prevLabel, onPressed: () => context.go(prevRoute)),
              circleButton(
                context,
                icon: Icons.home,
                onTap: () => context.go('/main-page'),
                iconSize: 40.0
              ),
              _dateButton(label: nextLabel, onPressed: () => context.go(nextRoute)),
              circleButton(
                context,
                icon: Icons.arrow_forward,
                onTap: () => context.go(nextRoute),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dateButton({required String label, required VoidCallback onPressed}) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    );
  }
}
