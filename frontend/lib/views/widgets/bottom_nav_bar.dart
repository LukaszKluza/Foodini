import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:frontend/views/widgets/circle_button.dart';
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
    return  ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
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
                icon: Icons.arrow_back_rounded,
                onTap: (mode == NavBarMode.normal ? Navigator.of(context).canPop() : prevRoute != null) ? () {
                  if (mode == NavBarMode.normal) {
                    context.pop();
                  } else if (prevRoute != null) {
                    context.go(prevRoute!);
                  }
                } : null,
              ),
              circleButton(
                context,
                icon: Icons.home_rounded,
                onTap: currentRoute != '/main-page'
                    ? () => context.go('/main-page')
                    : null,
                iconSize: 40.0
              ),
              circleButton(
                context,
                icon: Icons.arrow_forward_rounded,
                onTap: (mode == NavBarMode.wizard &&
                    nextRoute != null &&
                    isNextRouteEnabled)
                    ? () => context.go(nextRoute!)
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
