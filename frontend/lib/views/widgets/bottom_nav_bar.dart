import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

enum NavBarMode { normal, wizard }

class BottomNavBar extends StatelessWidget {
  final String currentRoute;
  final NavBarMode mode;
  final String? nextRoute;
  final String? prevRoute;

  const BottomNavBar({
    super.key,
    required this.currentRoute,
    this.mode = NavBarMode.normal,
    this.nextRoute,
    this.prevRoute,
  });

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildBackButton(context),
          _buildHomeButton(context),
          _buildNextButton(context),
        ],
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    final canPop = Navigator.of(context).canPop();
    final isActive = mode == NavBarMode.normal ? canPop : prevRoute != null;

    return _buildNavButton(
      icon: Icons.arrow_back,
      isActive: isActive,
      onPressed:
          isActive
              ? () {
                if (mode == NavBarMode.normal) {
                  context.pop();
                } else if (prevRoute != null) {
                  context.go(prevRoute!);
                }
              }
              : null,
    );
  }

  Widget _buildHomeButton(BuildContext context) {
    final isActive = currentRoute != '/main-page';
    return _buildNavButton(
      icon: Icons.home,
      isActive: isActive,
      onPressed: isActive ? () => context.go('/main-page') : null,
    );
  }

  Widget _buildNextButton(BuildContext context) {
    final isActive = mode == NavBarMode.wizard && nextRoute != null;
    return _buildNavButton(
      icon: Icons.arrow_forward,
      isActive: isActive,
      onPressed: isActive ? () => context.go(nextRoute!) : null,
    );
  }

  Widget _buildNavButton({
    required IconData icon,
    required bool isActive,
    required VoidCallback? onPressed,
  }) {
    return IconButton(
      icon: Icon(icon),
      iconSize: 24,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
      color: isActive ? Colors.blue : Colors.grey,
      onPressed: onPressed,
    );
  }
}
