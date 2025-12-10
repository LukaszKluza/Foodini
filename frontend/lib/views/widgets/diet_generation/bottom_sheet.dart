import 'package:flutter/material.dart';
import 'package:frontend/config/app_config.dart';
import 'package:frontend/l10n/app_localizations.dart';
import 'package:frontend/models/diet_generation/macros_summary.dart';
import 'package:frontend/models/diet_generation/meal_type.dart';
import 'package:frontend/views/screens/diet_generation/meal_details_screen.dart';
import 'package:frontend/views/widgets/diet_generation/macros_items.dart';

class CustomBottomSheet extends StatelessWidget {
  final MacrosSummary mealTypeMacrosSummary;
  final MealType mealType;

  const CustomBottomSheet({super.key, required this.mealTypeMacrosSummary, required this.mealType});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [getShadowBox()],
      ),
      child: ExpansionTile(
        initiallyExpanded: true,
        shape: RoundedRectangleBorder(side: BorderSide.none),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${AppLocalizations.of(context)!.macrosSummary} ${AppConfig.mealTypeLabels(context)[mealType]}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    buildCarbsItem(context, mealTypeMacrosSummary.carbs),
                    buildFatItem(context, mealTypeMacrosSummary.fat),
                    buildProteinItem(context, mealTypeMacrosSummary.protein),
                    buildCaloriesItem(context, mealTypeMacrosSummary.calories)
                  ],
                ),
                // const SizedBox(height: 10),
                // Row(
                //   children: [
                //     ActionButton(onPressed: () {}, color: Colors.redAccent, label: AppLocalizations.of(context)!.skipMeal)
                //   ],
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}