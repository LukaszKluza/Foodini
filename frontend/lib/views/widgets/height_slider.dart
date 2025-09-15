import 'package:flutter/material.dart';

import 'package:frontend/config/constants.dart';
import 'package:frontend/utils/user_details/profile_details_validators.dart';
import 'package:frontend/l10n/app_localizations.dart';

class HeightSlider extends StatelessWidget {
  final double min;
  final double max;
  final double value;
  final ValueChanged<double> onChanged;

  const HeightSlider({
    super.key,
    this.min = Constants.minHeight,
    this.max = Constants.maxHeight,
    required this.value,
    required this.onChanged,
  });

  void _showHeightDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final controller = TextEditingController(text: value.toStringAsFixed(1));

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(AppLocalizations.of(context)!.enterYourHeight),
            content: Form(
              key: formKey,
              child: TextFormField(
                key: Key('height-cm'),
                controller: controller,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.heightCm,
                ),
                validator: (value) => validateHeight(value, context),
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
                    final value = double.tryParse(controller.text);
                    if (value != null) {
                      onChanged(value);
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
          onTap: () => _showHeightDialog(context),
          child: Text(
            '${AppLocalizations.of(context)!.height}: ${value.toStringAsFixed(1)} ${AppLocalizations.of(context)!.cm}',
          ),
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: (max - min).toInt() * 10,
          label:
              '${value.toStringAsFixed(1)} ${AppLocalizations.of(context)!.cm}',
          onChanged: onChanged,
        ),
      ],
    );
  }
}
