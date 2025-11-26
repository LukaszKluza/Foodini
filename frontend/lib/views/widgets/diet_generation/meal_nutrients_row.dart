import 'package:flutter/cupertino.dart';
import 'package:frontend/models/diet_generation/macros_summary.dart';
import 'package:frontend/views/widgets/diet_generation/chips.dart';

class MealNutrientsRow extends StatelessWidget {
  final MacrosSummary macrosSummary;
  final int breakpoint;

  const MealNutrientsRow({super.key, required this.macrosSummary, required this.breakpoint});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= breakpoint) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  carbsChip(context, macrosSummary),
                  const SizedBox(width: 8),
                  fatChip(context, macrosSummary),
                  const SizedBox(width: 8),
                  proteinChip(context, macrosSummary),
                ],
              ),
              Row(children: [caloriesChip(context, macrosSummary)]),
            ],
          );
        } else {
          return Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              carbsChip(context, macrosSummary),
              fatChip(context, macrosSummary),
              proteinChip(context, macrosSummary),
              caloriesChip(context, macrosSummary, width: double.infinity),
            ],
          );
        }
      },
    );
  }
}
