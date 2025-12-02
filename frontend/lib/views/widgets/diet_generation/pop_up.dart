import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/blocs/diet_generation/daily_summary_bloc.dart';
import 'package:frontend/events/diet_generation/daily_summary_events.dart';
import 'package:frontend/l10n/app_localizations.dart';
import 'package:frontend/models/diet_generation/custom_meal_update_request.dart';
import 'package:frontend/models/diet_generation/meal_info.dart';
import 'package:frontend/models/diet_generation/meal_type.dart';
import 'package:frontend/models/diet_generation/remove_meal_request.dart';
import 'package:frontend/utils/diet_generation/meal_item_validators.dart';
import 'package:frontend/views/widgets/diet_generation/action_button.dart';
import 'package:frontend/views/widgets/diet_generation/enter_barcode_pop_up.dart';
import 'package:uuid/uuid.dart';

VoidCallback showPopUp(
  BuildContext context,
  DateTime day,
  MealType updatedMealType,
  UuidValue updatedMealId, {
  MealInfo? mealInfo,
}) {
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
      validator: (value) => validator(value),
    );
  }

  void showEnterBarcodePopup(
      BuildContext context,
      DateTime day,
      UuidValue updatedMealId, {
        MealInfo? mealInfo,
      }) {
    showDialog(
      context: context,
      builder: (_) => EnterBarcodePopup(
        day: day,
        mealType: updatedMealType,
      ),
    );
  }

  final formKey = GlobalKey<FormState>();

  return () {
    showDialog(
      context: context,
      builder: (context) {
        final nameController = TextEditingController(
          text: mealInfo?.name ?? '',
        );
        final carbsController = TextEditingController(
          text: mealInfo?.carbs.toString() ?? '',
        );
        final fatController = TextEditingController(
          text: mealInfo?.fat.toString() ?? '',
        );
        final proteinController = TextEditingController(
          text: mealInfo?.protein.toString() ?? '',
        );
        final caloriesController = TextEditingController(
          text: mealInfo?.calories.toString() ?? '',
        );
        final weightController = TextEditingController(
          text: mealInfo?.weight.toString() ?? '',
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
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (mealInfo == null)
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
                    const SizedBox(height: 12),
                    editableTextFormField(
                      context,
                      weightController,
                          (value) => validateCalories(value, context),
                      AppLocalizations.of(context)!.weightG,
                    ),
                    const SizedBox(height: 18),
                    if (mealInfo == null) ...[
                      Row(
                        children: [
                          ActionButton(
                            onPressed: () {
                              Navigator.pop(context);
                              showEnterBarcodePopup(
                                context,
                                day,
                                updatedMealId,
                                mealInfo: mealInfo,
                              );
                            },
                            color: Colors.orangeAccent,
                            label: AppLocalizations.of(context)!.scanProductBarCode,
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
                          onPressed: () {
                            if (formKey.currentState!.validate()) {
                              var customMealUpdateRequest =
                                CustomMealUpdateRequest(
                                  day: day,
                                  mealType: updatedMealType,
                                  mealId:
                                    mealInfo != null ? updatedMealId : null,
                                  customName:
                                    mealInfo == null ? nameController.text : null,
                                  customCalories: int.tryParse(caloriesController.text)!,
                                  customProtein: double.tryParse(proteinController.text)!,
                                  customCarbs: double.tryParse(carbsController.text)!,
                                  customFat: double.tryParse(fatController.text)!,
                                  eatenWeight: int.tryParse(weightController.text)!,
                                );
                              context.read<DailySummaryBloc>().add(
                                UpdateMeal(
                                  customMealUpdateRequest: customMealUpdateRequest,
                                ),
                              );
                              Navigator.pop(context);
                            }
                          },
                          color: Colors.lightGreen,
                          label: AppLocalizations.of(context)!.save,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  };
}

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
