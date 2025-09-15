import 'package:flutter/material.dart';

import 'package:frontend/config/constants.dart';
import 'package:frontend/l10n/app_localizations.dart';
import 'package:frontend/utils/user_details/profile_details_validators.dart';

class WeightSlider extends StatelessWidget {
  final double min;
  final double max;
  final double value;
  final ValueChanged<double> onChanged;
  final String label;
  final String dialogTitle;
  final FormFieldValidator<String>? validator;

  const WeightSlider({
    super.key,
    this.min = Constants.minWeight,
    this.max = Constants.maxWeight,
    required this.value,
    required this.onChanged,
    required this.label,
    required this.dialogTitle,
    this.validator,
  });

  void _showWeightDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final controller = TextEditingController(text: value.toStringAsFixed(1));

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(dialogTitle),
        content: Form(
          key: formKey,
          child: TextFormField(
            key: const Key('weight_kg'),
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.weightKg,
            ),
            validator: validator ?? (val) => validateWeight(val, context),
          ),
        ),
        actions: [
          ElevatedButton(
            child: Text(AppLocalizations.of(context)!.cancel),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: Text(AppLocalizations.of(context)!.ok),
            onPressed: () {
              if (formKey.currentState!.validate()) {
                final newValue = double.tryParse(controller.text);
                if (newValue != null) {
                  onChanged(newValue);
                  Navigator.pop(context);
                }
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => _showWeightDialog(context),
          child: Text(
            '$label: ${value.toStringAsFixed(1)} ${AppLocalizations.of(context)!.kg}',
          ),
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: (max - min).toInt() * 10,
          label: '${value.toStringAsFixed(1)} ${AppLocalizations.of(context)!.kg}',
          onChanged: onChanged,
        ),
      ],
    );
  }
}
