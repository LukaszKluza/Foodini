import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/blocs/diet_generation/daily_summary_bloc.dart';
import 'package:frontend/events/diet_generation/daily_summary_events.dart';
import 'package:frontend/l10n/app_localizations.dart';
import 'package:frontend/models/diet_generation/meal_type.dart';
import 'package:frontend/models/diet_generation/remove_meal_request.dart';
import 'package:frontend/views/widgets/diet_generation/animated_button.dart';
import 'package:uuid/uuid.dart';

VoidCallback showDeleteMealPopUp(
  BuildContext context,
  DateTime day,
  MealType mealType,
  UuidValue mealId,
  {required String mealName}
) {
  return () {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 12,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    AppLocalizations.of(context)!.confirmRemovingMeal,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      ActionButton(
                        onPressed: () => Navigator.pop(context),
                        color: Colors.grey[500]!,
                        label: AppLocalizations.of(context)!.cancel,
                      ),
                      const SizedBox(width: 12),
                      ActionButton(
                        onPressed: () {
                          final request = RemoveMealRequest(
                            day: day,
                            mealType: mealType,
                            mealId: mealId,
                          );
                          context.read<DailySummaryBloc>().add(RemoveMeal(removeMealRequest: request));
                          Navigator.pop(context);
                        },
                        color: Colors.redAccent,
                        label: AppLocalizations.of(context)!.delete,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  };
}
