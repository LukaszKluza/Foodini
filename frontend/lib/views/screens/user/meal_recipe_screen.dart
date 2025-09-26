import 'package:flutter/material.dart';
import 'package:frontend/config/styles.dart';
import 'package:frontend/l10n/app_localizations.dart';
import 'package:frontend/views/widgets/bottom_nav_bar.dart';
import 'package:go_router/go_router.dart';

class MealRecipeScreen extends StatelessWidget {
  final String mealId;

  const MealRecipeScreen({super.key, required this.mealId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            AppLocalizations.of(context)!.dietPreferences,
            style: Styles.titleStyle,
          ),
        ),
      ),
      body: _MealRecipe(),
      bottomNavigationBar: BottomNavBar(
        currentRoute: GoRouterState.of(context).uri.path,
        mode: NavBarMode.normal,
      ),
    );
  }
}

class _MealRecipe extends StatefulWidget {
  @override
  State<_MealRecipe> createState() => _MealRecipeState();
}

class _MealRecipeState extends State<_MealRecipe> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            AppLocalizations.of(context)!.welcome,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => context.go('/login'),
            child: Text(AppLocalizations.of(context)!.login),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => context.go('/register'),
            child: Text(AppLocalizations.of(context)!.register),
          ),
        ],
      ),
    );
  }
}
