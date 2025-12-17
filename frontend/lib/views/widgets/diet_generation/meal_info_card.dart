import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:frontend/models/diet_generation/macros_summary.dart';
import 'package:frontend/models/diet_generation/meal_info.dart';
import 'package:frontend/views/widgets/diet_generation/meal_nutrients_row.dart';
import 'package:go_router/go_router.dart';

class MealInfoCard extends StatelessWidget {
  final BuildContext context;
  final MealInfo activeMealInfo;

  const MealInfoCard({
    super.key,
    required this.context,
    required this.activeMealInfo,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () {
          final mealId = activeMealInfo.mealId;
          if (activeMealInfo.description != null) {
            context.push('/meal-recipe/$mealId');
          }
        },
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFF2BA35),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: AutoSizeText(
                      activeMealInfo.name,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      minFontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              MealNutrientsRow(
                  macrosSummary: MacrosSummary(
                      carbs: activeMealInfo.plannedCarbs,
                      fat: activeMealInfo.plannedFat,
                      protein: activeMealInfo.plannedProtein,
                      calories: activeMealInfo.plannedCalories
                  ),
                  breakpoint: 350
              )
            ],
          ),
        ),
      ),
    );
  }
}
