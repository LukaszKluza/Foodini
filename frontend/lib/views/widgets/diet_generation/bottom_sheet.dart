import 'package:flutter/material.dart';
import 'package:frontend/l10n/app_localizations.dart';
import 'package:frontend/views/screens/diet_generation/meal_details_screen.dart';
import 'package:frontend/views/widgets/diet_generation/action_button.dart';

class CustomBottomSheet extends StatelessWidget {
  const CustomBottomSheet({super.key});

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
              AppLocalizations.of(context)!.macrosSummary,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    buildCarbsItem(context, 10),
                    buildFatItem(context, 12),
                    buildProteinItem(context, 21),
                    buildCaloriesItem(context, 1123)
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    ActionButton(onPressed: () {}, color: Colors.orange, label: AppLocalizations.of(context)!.submit),
                    const SizedBox(width: 12),
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