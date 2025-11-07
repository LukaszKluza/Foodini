import 'package:flutter/material.dart';
import 'package:frontend/l10n/app_localizations.dart';

Column buildMacroItem(
    BuildContext context,
    Icon icon,
    String value,
    String key,
    ) {
  return Column(
    children: [
      icon,
      SizedBox(height: 4),
      Text(key, style: TextStyle(color: Colors.grey, fontSize: 12)),
      Text(value, style: TextStyle(fontWeight: FontWeight.bold)),
    ],
  );
}

Column buildCarbsItem(BuildContext context, double value) {
  return buildMacroItem(
    context,
    Icon(Icons.local_fire_department, color: Colors.orange),
    '${value.toStringAsFixed(2)}g',
    AppLocalizations.of(context)!.carbsG,
  );
}

Column buildFatItem(BuildContext context, double value) {
  return buildMacroItem(
    context,
    Icon(Icons.bubble_chart, color: Colors.yellow[700]!),
    '${value.toStringAsFixed(2)}g',
    AppLocalizations.of(context)!.fatG,
  );
}

Column buildProteinItem(BuildContext context, double value) {
  return buildMacroItem(
    context,
    Icon(Icons.fitness_center, color: Colors.green),
    '${value.toStringAsFixed(2)}g',
    AppLocalizations.of(context)!.proteinG,
  );
}

Column buildCaloriesItem(BuildContext context, int value) {
  return buildMacroItem(
    context,
    Icon(Icons.local_fire_department, color: Colors.redAccent),
    '${value}kcal',
    AppLocalizations.of(context)!.calories,
  );
}