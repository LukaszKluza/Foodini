import 'package:flutter/material.dart';
import 'package:frontend/l10n/app_localizations.dart';
import 'package:frontend/models/diet_generation/macros_summary.dart';

Widget fatChip(BuildContext context, MacrosSummary macrosSummary){
  return _macroChip(macrosSummary.fat ,AppLocalizations.of(context)!.g_grams , Color(0xFFFFCA28), label: AppLocalizations.of(context)!.f_fat);
}

Widget proteinChip(BuildContext context, MacrosSummary macrosSummary){
  return _macroChip(macrosSummary.protein, AppLocalizations.of(context)!.g_grams, Color(0xFF0687F6), label: AppLocalizations.of(context)!.p_protein);
}

Widget carbsChip(BuildContext context, MacrosSummary macrosSummary){
  return _macroChip(macrosSummary.carbs, AppLocalizations.of(context)!.g_grams, Color(0xFF3DAF43), label: AppLocalizations.of(context)!.c_carbs);
}

Widget caloriesChip(BuildContext context, MacrosSummary macrosSummary, {double? width}){
  return _macroChip(macrosSummary.calories, AppLocalizations.of(context)!.kcal, Color(0xFFBA68C8), width: width);
}

Widget _macroChip(
    num value, String unitName, Color color,
    {String? label, double? width}) {

  String text = label != null ? '$label: $value $unitName' : '$value $unitName';
  return Container(
    width: width,
    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
    decoration: BoxDecoration(
      color: color.withAlpha(200),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}
