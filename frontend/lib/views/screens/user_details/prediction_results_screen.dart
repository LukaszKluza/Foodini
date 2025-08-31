import 'package:flutter/material.dart';
import 'package:frontend/config/styles.dart';
import 'package:frontend/l10n/app_localizations.dart';
import 'package:frontend/models/user_details/predicted_calories.dart';
import 'package:frontend/views/widgets/bottom_nav_bar.dart';
import 'package:go_router/go_router.dart';

class PredictionResultsScreen extends StatelessWidget {
  final PredictedCalories predictedCalories;

  const PredictionResultsScreen({super.key, required this.predictedCalories});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            AppLocalizations.of(context)!.caloriesPrediction,
            style: Styles.titleStyle,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(35.0),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${AppLocalizations.of(context)!.predictedCalories}: ${predictedCalories.targetCalories} kcal',
                style: Styles.titleStyle,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              Text(
                '${AppLocalizations.of(context)!.bmr}: ${predictedCalories.bmr} kcal',
              ),
              Text(
                '${AppLocalizations.of(context)!.tdee}: ${predictedCalories.tdee} kcal',
              ),
              SizedBox(height: 16),
              Text('${AppLocalizations.of(context)!.predictedMacros}:'),
              Text(
                '${predictedCalories.predictedMacros.protein}g protein, '
                '${predictedCalories.predictedMacros.fat}g fats, '
                '${predictedCalories.predictedMacros.carbs}g carbs',
              ),
              if (predictedCalories.dietDurationDays != null)
                Text(
                  '${AppLocalizations.of(context)!.dietDuration}: ${predictedCalories.dietDurationDays}',
                ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentRoute: GoRouterState.of(context).uri.path,
        mode: NavBarMode.wizard,
        prevRoute: '/calories-prediction',
      ),
    );
  }
}
