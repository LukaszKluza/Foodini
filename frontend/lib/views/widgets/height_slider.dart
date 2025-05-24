import 'package:flutter/material.dart';
import 'package:frontend/config/app_config.dart';

import 'package:frontend/utils/profile_details_validators.dart';

class HeightSlider extends StatefulWidget {
  final double min;
  final double max;
  final double initialValue;
  final ValueChanged<double> onChanged;

  const HeightSlider({
    super.key,
    this.min = AppConfig.minHeight,
    this.max = AppConfig.maxHeight,
    required this.initialValue,
    required this.onChanged,
  });

  @override
  HeightSliderState createState() => HeightSliderState();
}

class HeightSliderState extends State<HeightSlider> {
  final _formKey = GlobalKey<FormState>();
  late double _height;

  @override
  void initState() {
    super.initState();
    _height = widget.initialValue;
  }

  void _showHeightDialog() {
    final controller = TextEditingController(text: _height.toStringAsFixed(1));

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(AppConfig.enterYourHeight),
            content: Form(
              key: _formKey,
              child: TextFormField(
                key: Key(AppConfig.heightCm),
                controller: controller,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(labelText: AppConfig.heightCm),
                validator: validateHeight,
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
                        _height = value;
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
          onTap: _showHeightDialog,
          child: Text(
            "${AppConfig.height}: ${_height.toStringAsFixed(1)} ${AppConfig.cm}",
          ),
        ),
        GestureDetector(
          // onTap: _showHeightDialog,
          child: Slider(
            value: _height,
            min: widget.min,
            max: widget.max,
            divisions: (widget.max - widget.min).toInt() * 10,
            label: "${_height.toStringAsFixed(1)} ${AppConfig.cm}",
            onChanged: (value) {
              setState(() {
                _height = value;
              });
              widget.onChanged(value);
            },
          ),
        ),
      ],
    );
  }
}
