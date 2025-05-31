import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:frontend/config/app_config.dart';
import 'package:frontend/config/constants.dart';
import 'package:frontend/config/styles.dart';
import 'package:frontend/events/diet_form_events.dart';
import 'package:frontend/utils/user_details/diet_preferences_validators.dart';
import 'package:multi_select_flutter/chip_display/multi_select_chip_display.dart';
import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
import 'package:frontend/views/widgets/weight_slider.dart';
import 'package:frontend/l10n/app_localizations.dart';
import 'package:frontend/models/user_details/allergy.dart';
import 'package:frontend/models/user_details/diet_intensity.dart';
import 'package:frontend/models/user_details/diet_type.dart';
import 'package:frontend/blocs/diet_form_bloc.dart';

class DietPreferencesScreen extends StatelessWidget {
  const DietPreferencesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            AppLocalizations.of(context)!.dietPreferences,
            style: Styles.titleStyle,
          ),
        ),
      ),
      body: _DietPreferencesForm(),
    );
  }
}

class _DietPreferencesForm extends StatefulWidget {
  @override
  State<_DietPreferencesForm> createState() => _DietPreferencesFormState();
}

class _DietPreferencesFormState extends State<_DietPreferencesForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _dietTypeController = TextEditingController();
  final TextEditingController _allergiesController = TextEditingController();
  final TextEditingController _dietGoalController = TextEditingController();
  final TextEditingController _mealsPerDeyController = TextEditingController();
  final TextEditingController _dietIntensityController =
      TextEditingController();

  DietType? _selectedDietType;
  List<Allergy>? _selectedAllergies;
  DietIntensity? _selectedDietIntensity;

  double _selectedDietGoal = 70;
  int _selectedMealsPerDay = 3;
  String? _message;
  final TextStyle _messageStyle = Styles.errorStyle;

  @override
  void initState() {
    super.initState();

    DietFormBloc dietFormBloc = context.read<DietFormBloc>();

    final state = dietFormBloc.state;
    if (state.weight != null) {
      _selectedDietGoal = state.weight!;
    }
  }

  @override
  void dispose() {
    _dietTypeController.dispose();
    _allergiesController.dispose();
    _dietGoalController.dispose();
    _mealsPerDeyController.dispose();
    _dietIntensityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fields = [
      DropdownButtonFormField<DietType>(
        key: Key("diet_type"),
        value: _selectedDietType,
        decoration: InputDecoration(
          labelText: AppLocalizations.of(context)!.dietType,
        ),
        items:
            DietType.values.map((diet) {
              return DropdownMenuItem<DietType>(
                value: diet,
                child: Text(
                  AppConfig.dietTypeLabels(context)[diet]!,
                  style: TextStyle(color: Colors.black),
                ),
              );
            }).toList(),
        onChanged: (value) {
          setState(() {
            _selectedDietType = value!;
          });
          context.read<DietFormBloc>().add(UpdateDietType(value!));
        },
        validator: (value) => validateDietType(value, context),
      ),
      MultiSelectDialogField<Allergy>(
        items:
            Allergy.values.map((allergy) {
              return MultiSelectItem<Allergy>(
                allergy,
                AppConfig.allergyLabels(context)[allergy]!,
              );
            }).toList(),
        title: Text(AppLocalizations.of(context)!.allergies),
        selectedColor: Colors.purpleAccent,
        chipDisplay: MultiSelectChipDisplay(
          chipColor: Colors.purpleAccent[50],
          textStyle: TextStyle(color: Colors.black),
        ),
        buttonText: Text(AppLocalizations.of(context)!.allergies),
        onConfirm: (values) {
          setState(() {
            _selectedAllergies = values;
          });
          context.read<DietFormBloc>().add(UpdateAllergies(values));
        },
      ),
      WeightSlider(
        initialValue: _selectedDietGoal,
        validator: (value) => validateDietGoal(value, context),
        onChanged: (value) {
          setState(() {
            _selectedDietGoal = value;
          });
          context.read<DietFormBloc>().add(UpdateDietGoal(value));
        },
        label: AppLocalizations.of(context)!.dietGoal,
        dialogTitle: AppLocalizations.of(context)!.enterYourDietGoal,
      ),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppLocalizations.of(context)!.mealsPerDay),
          SizedBox(height: 8),
          FractionallySizedBox(
            widthFactor: 1,
            child: SegmentedButton<int>(
              segments: [
                for (var i = 1; i <= Constants.maxMealsPerDay; i++)
                  ButtonSegment(value: i, label: Text('$i')),
              ],
              selected: <int>{_selectedMealsPerDay},
              onSelectionChanged: (newSelection) {
                setState(() => _selectedMealsPerDay = newSelection.first);
                context.read<DietFormBloc>().add(
                  UpdateMealsPerDay(_selectedMealsPerDay),
                );
              },
            ),
          ),
        ],
      ),
      DropdownButtonFormField<DietIntensity>(
        key: Key("diet_intensity"),
        value: _selectedDietIntensity,
        decoration: InputDecoration(
          labelText: AppLocalizations.of(context)!.dietIntensity,
        ),
        items:
            DietIntensity.values.map((diet) {
              return DropdownMenuItem<DietIntensity>(
                value: diet,
                child: Text(
                  AppConfig.dietIntensityLabels(context)[diet]!,
                  style: TextStyle(color: Colors.black),
                ),
              );
            }).toList(),
        onChanged: (value) {
          setState(() {
            _selectedDietIntensity = value!;
          });
          context.read<DietFormBloc>().add(UpdateDietIntensity(value!));
        },
        validator: (value) => validateDietIntensity(value, context),
      ),
      if (_message != null)
        Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(_message!, style: _messageStyle),
        ),
    ];

    return Padding(
      padding: EdgeInsets.all(35.0),
      child: Form(
        key: _formKey,
        child: ListView.separated(
          shrinkWrap: true,
          itemCount: fields.length,
          separatorBuilder: (_, __) => SizedBox(height: 20),
          itemBuilder: (_, index) => fields[index],
        ),
      ),
    );
  }
}
