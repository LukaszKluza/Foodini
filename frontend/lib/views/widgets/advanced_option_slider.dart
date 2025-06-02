import 'package:flutter/material.dart';

import 'package:frontend/l10n/app_localizations.dart';

class PercentageOptionSlider extends StatefulWidget {
  final double min;
  final double max;
  final double initialValue;
  final String propertiesName;
  final String pupUpKey;
  final String alertDialogTitle;
  final String inputDecorator;
  final String? Function(String?) validator;
  final ValueChanged<double> onChanged;

  const PercentageOptionSlider({
    super.key,
    this.min = 0,
    this.max = 100,
    required this.initialValue,
    required this.pupUpKey,
    required this.propertiesName,
    required this.alertDialogTitle,
    required this.inputDecorator,
    required this.validator,
    required this.onChanged,
  });

  @override
  PercentageOptionSliderState createState() => PercentageOptionSliderState();
}

class PercentageOptionSliderState extends State<PercentageOptionSlider> {
  final _formKey = GlobalKey<FormState>();
  late double _value;

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue;
  }

  void _showPercentageOptionDialog() {
    final controller = TextEditingController(text: _value.toStringAsFixed(1));

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(widget.alertDialogTitle),
            content: Form(
              key: _formKey,
              child: TextFormField(
                key: Key(widget.pupUpKey),
                controller: controller,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(labelText: widget.inputDecorator),
                validator: widget.validator,
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
                        _value = value;
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
          onTap: _showPercentageOptionDialog,
          child: Text(
            '${widget.propertiesName}: ${_value.toStringAsFixed(1)}%',
          ),
        ),
        GestureDetector(
          child: Slider(
            key: Key(widget.pupUpKey),
            value: _value,
            min: widget.min,
            max: widget.max,
            divisions: (widget.max - widget.min).toInt(),
            label: '${_value.toStringAsFixed(1)}%',
            onChanged: (value) {
              setState(() {
                _value = value;
              });
              widget.onChanged(value);
            },
          ),
        ),
      ],
    );
  }
}
