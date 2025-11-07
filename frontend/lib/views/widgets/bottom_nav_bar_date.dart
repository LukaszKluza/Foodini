import 'package:flutter/material.dart';
import 'package:frontend/views/widgets/nav_icon_button.dart';
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

    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8.0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            NavIconButton(
              icon: Icons.arrow_back,
              onPressed: () => context.go(prevRoute),
            ),

            _buildDateButton(
              label: prevLabel,
              onPressed: () => context.go(prevRoute),
            ),

            NavIconButton(
              icon: Icons.home,
              onPressed: () => context.go('/main-page')
            ),

            _buildDateButton(
              label: nextLabel,
              onPressed: () => context.go(nextRoute),
            ),

            NavIconButton(
              icon: Icons.arrow_forward,
              onPressed: () => context.go(nextRoute),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateButton({
    required String label,
    required VoidCallback onPressed,
  }) {

    
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
    );
  }
}
