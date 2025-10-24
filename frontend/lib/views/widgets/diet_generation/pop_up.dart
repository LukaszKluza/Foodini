import 'package:flutter/material.dart';
import 'package:frontend/l10n/app_localizations.dart';
import 'package:frontend/models/diet_generation/meal_item.dart';
import 'package:frontend/utils/diet_generation/meal_item_validators.dart';
import 'package:frontend/views/widgets/diet_generation/action_button.dart';

VoidCallback showPopUp(BuildContext context, {MealItem? mealItem}) {
  TextFormField editableTextFormField(
    BuildContext context,
    TextEditingController textEditingController,
    Function(String?) validator,
    String label, {
    TextInputType? textInputType = TextInputType.number,
  }) {
    return TextFormField(
      controller: textEditingController,
      decoration: InputDecoration(
        labelText: label,
        errorMaxLines: 2,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      keyboardType: textInputType,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: (value) => validator(value)
    );
  }

  return () {
    showDialog(
      context: context,
      builder: (context) {
        final nameController = TextEditingController(
          text: mealItem?.name ?? '',
        );
        final carbsController = TextEditingController(
          text: mealItem?.carbs.toString() ?? '',
        );
        final fatController = TextEditingController(
          text: mealItem?.fat.toString() ?? '',
        );
        final proteinController = TextEditingController(
          text: mealItem?.protein.toString() ?? '',
        );
        final caloriesController = TextEditingController(
          text: mealItem?.calories.toString() ?? '',
        );

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 12,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  editableTextFormField(
                    context,
                    nameController,
                    (value) => validateMealItemName(value, context),
                    AppLocalizations.of(context)!.mealName,
                    textInputType: TextInputType.text,
                  ),
                  const SizedBox(height: 12),
                  editableTextFormField(
                    context,
                    carbsController,
                    (value) => validateMacro(value, context),
                    AppLocalizations.of(context)!.carbsG,
                  ),
                  const SizedBox(height: 12),
                  editableTextFormField(
                    context,
                    fatController,
                    (value) => validateMacro(value, context),
                    AppLocalizations.of(context)!.fatG,
                  ),
                  const SizedBox(height: 12),
                  editableTextFormField(
                    context,
                    proteinController,
                    (value) => validateMacro(value, context),
                    AppLocalizations.of(context)!.proteinG,
                  ),
                  const SizedBox(height: 12),
                  editableTextFormField(
                    context,
                    caloriesController,
                    (value) => validateCalories(value, context),
                    AppLocalizations.of(context)!.calories,
                  ),
                  const SizedBox(height: 18),
                  if (mealItem == null) ...[
                    Row(
                      children: [
                        ActionButton(
                          onPressed: () => Navigator.pop(context),
                          color: Colors.orangeAccent,
                          label:
                              AppLocalizations.of(context)!.scanProductBarCode,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],
                  Row(
                    children: [
                      ActionButton(
                        onPressed: () => Navigator.pop(context),
                        color: Colors.grey[500]!,
                        label: AppLocalizations.of(context)!.cancel,
                      ),
                      const SizedBox(width: 12),
                      ActionButton(
                        onPressed: () => Navigator.pop(context),
                        color: Colors.lightGreen,
                        label: AppLocalizations.of(context)!.save,
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
