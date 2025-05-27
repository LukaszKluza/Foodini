import 'package:flutter/material.dart';
import 'package:frontend/config/app_config.dart';

import 'package:frontend/utils/diet_preferences_validators.dart';

class WeightSlider extends StatefulWidget {
  final double min;
  final double max;
  final double initialValue;
  final ValueChanged<double> onChanged;

  const WeightSlider({
    super.key,
    this.min = AppConfig.minWeight,
    this.max = AppConfig.maxWeight,
    required this.initialValue,
    required this.onChanged,
  });

  @override
  WeightSliderState createState() => WeightSliderState();
}

class WeightSliderState extends State<WeightSlider> {
  final _formKey = GlobalKey<FormState>();
  late double _weight;

  @override
  void initState() {
    super.initState();
    _weight = widget.initialValue;
  }

  void _showWeightDialog() {
    final controller = TextEditingController(text: _weight.toStringAsFixed(1));

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(AppConfig.enterYourDietGoal),
            content: Form(
              key: _formKey,
              child: TextFormField(
                key: Key(AppConfig.weightKg),
                controller: controller,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(labelText: AppConfig.weightKg),
                validator: validateWeight,
              ),
            ),
            actions: [
              ElevatedButton(
                child: Text(AppConfig.cancel),
                onPressed: () => Navigator.pop(context),
              ),
              ElevatedButton(
                child: Text(AppConfig.ok),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final value = double.tryParse(controller.text);
                    if (value != null) {
                      setState(() {
                        _weight = value;
                      });
                      widget.onChanged(value);
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
          onTap: _showWeightDialog,
          child: Text(
            "${AppConfig.dietGoal}: ${_weight.toStringAsFixed(1)} ${AppConfig.kg}",
          ),
        ),
        GestureDetector(
          child: Slider(
            value: _weight,
            min: widget.min,
            max: widget.max,
            divisions: (widget.max - widget.min).toInt() * 10,
            label: "${_weight.toStringAsFixed(1)} ${AppConfig.kg}",
            onChanged: (value) {
              setState(() {
                _weight = value;
              });
              widget.onChanged(value);
            },
          ),
        ),
      ],
    );
  }
}
