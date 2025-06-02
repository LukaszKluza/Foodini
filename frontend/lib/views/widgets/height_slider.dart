import 'package:flutter/material.dart';

import 'package:frontend/config/constants.dart';
import 'package:frontend/utils/user_details/profile_details_validators.dart';
import 'package:frontend/l10n/app_localizations.dart';

class HeightSlider extends StatefulWidget {
  final double min;
  final double max;
  final double initialValue;
  final ValueChanged<double> onChanged;

  const HeightSlider({
    super.key,
    this.min = Constants.minHeight,
    this.max = Constants.maxHeight,
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
            title: Text(AppLocalizations.of(context)!.enterYourHeight),
            content: Form(
              key: _formKey,
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
            '${AppLocalizations.of(context)!.height}: ${_height.toStringAsFixed(1)} ${AppLocalizations.of(context)!.cm}',
          ),
        ),
        GestureDetector(
          child: Slider(
            value: _height,
            min: widget.min,
            max: widget.max,
            divisions: (widget.max - widget.min).toInt() * 10,
            label:
                '${_height.toStringAsFixed(1)} ${AppLocalizations.of(context)!.cm}',
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
