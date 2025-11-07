import 'package:flutter/material.dart';
import 'package:frontend/views/widgets/nav_icon_button.dart';
import 'package:go_router/go_router.dart';

enum NavBarMode { normal, wizard }

class BottomNavBar extends StatelessWidget {
  final String currentRoute;
  final NavBarMode mode;
  final String? nextRoute;
  final String? prevRoute;
  final bool isNextRouteEnabled;

  const BottomNavBar({
    super.key,
    required this.currentRoute,
    this.mode = NavBarMode.normal,
    this.nextRoute,
    this.prevRoute,
    this.isNextRouteEnabled = true,
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

    return NavIconButton(
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
    return NavIconButton(
      icon: Icons.home,
      isActive: isActive,
      onPressed: isActive ? () => context.go('/main-page') : null,
    );
  }

  Widget _buildNextButton(BuildContext context) {
    final isActive =
        mode == NavBarMode.wizard && nextRoute != null && isNextRouteEnabled;
    return NavIconButton(
      icon: Icons.arrow_forward,
      isActive: isActive,
      onPressed: isActive ? () => context.go(nextRoute!) : null,
    );
  }
}
