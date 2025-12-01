import 'package:flutter/material.dart';
import 'package:frontend/l10n/app_localizations.dart';
import 'package:frontend/models/diet_generation/macros_summary.dart';
import 'package:frontend/views/screens/diet_generation/meal_details_screen.dart';
import 'package:frontend/views/widgets/diet_generation/action_button.dart';
import 'package:frontend/views/widgets/diet_generation/macros_items.dart';

class CustomBottomSheet extends StatelessWidget {
  final MacrosSummary mealTypeMacrosSummary;
  final DateTime selectedDate;

  const CustomBottomSheet({super.key, required this.mealTypeMacrosSummary, required this.selectedDate});

  @override
  Widget build(BuildContext context) {
    final displayDate =
        "${selectedDate.day.toString().padLeft(2, '0')}.${selectedDate.month.toString().padLeft(2, '0')}.${selectedDate.year}";
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
              '${AppLocalizations.of(context)!.macrosSummary} ${AppLocalizations.of(context)!.of_calories} $displayDate',
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
                const SizedBox(height: 10),
                Row(
                  children: [
                    ActionButton(onPressed: () {}, color: Colors.redAccent, label: AppLocalizations.of(context)!.skipMeal)
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}