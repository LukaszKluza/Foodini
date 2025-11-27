import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/blocs/diet_generation/daily_summary_bloc.dart';
import 'package:frontend/events/diet_generation/daily_summary_events.dart';
import 'package:frontend/l10n/app_localizations.dart';
import 'package:frontend/models/diet_generation/custom_meal_update_request.dart';
import 'package:frontend/models/diet_generation/meal_info.dart';
import 'package:frontend/models/diet_generation/meal_type.dart';
import 'package:frontend/utils/diet_generation/meal_item_validators.dart';
import 'package:frontend/views/widgets/diet_generation/action_button.dart';
import 'package:uuid/uuid.dart';

VoidCallback showEditMealPopUp(
  BuildContext context,
  DateTime day,
  MealType mealType,
  UuidValue mealItemId,
  MealInfo mealItemInfo,
) {
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

  final formKey = GlobalKey<FormState>();

  Widget _macroIcon(String text) {
    return Row(
      children: [
        Text(
          text,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }

  Widget _macroDivider() {
    return Transform.translate(
      offset: const Offset(0, -3),
      child: Text(
        '|',
        style: const TextStyle(
          fontSize: 40,
          color: Colors.white70,
          fontWeight: FontWeight.w400,
          height: 0.8,
        ),
      ),
    );
  }


  return () {
    showDialog(
      context: context,
      builder: (context) {
        final weightController = TextEditingController(
          text: mealItemInfo.unitWeight.toString(),
        );

        print(mealItemInfo.toJson());

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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.macrosPer100g,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFF7F50), Color(0xFFFFA500)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 10,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          // child:
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _macroIcon('${(mealItemInfo.calories!/mealItemInfo.unitWeight * 100).toStringAsFixed(0)} kcal'),
                              _macroDivider(),
                              _macroIcon(
                                  '${AppLocalizations.of(context)!.p_protein}: ${(mealItemInfo.protein!/ mealItemInfo.unitWeight * 100).toStringAsFixed(2)}g'
                              ),
                              _macroDivider(),
                              _macroIcon('${AppLocalizations.of(context)!.c_carbs}: ${(mealItemInfo.carbs!/mealItemInfo.unitWeight*100).toStringAsFixed(2)}g '),
                              _macroDivider(),
                              _macroIcon('${AppLocalizations.of(context)!.f_fat}: ${(mealItemInfo.fat!/mealItemInfo.unitWeight*100).toStringAsFixed(2)}g'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        editableTextFormField(
                          context,
                          weightController,
                              (value) => validateCalories(value, context),
                          AppLocalizations.of(context)!.weightG,
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
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
                                  mealType: mealType,
                                  mealId: mealItemId,
                                  customCalories: mealItemInfo.calories!,
                                  customProtein: mealItemInfo.protein!,
                                  customCarbs: mealItemInfo.carbs!,
                                  customFat: mealItemInfo.fat!,
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
