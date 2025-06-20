import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:frontend/config/app_config.dart';
import 'package:frontend/config/constants.dart';
import 'package:frontend/config/styles.dart';
import 'package:frontend/states/diet_form_states.dart';
import 'package:frontend/views/widgets/bottom_nav_bar.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/events/user_details/diet_form_events.dart';
import 'package:frontend/utils/user_details/diet_preferences_validators.dart';
import 'package:multi_select_flutter/chip_display/multi_select_chip_display.dart';
import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
import 'package:frontend/views/widgets/weight_slider.dart';
import 'package:frontend/l10n/app_localizations.dart';
import 'package:frontend/models/user_details/allergy.dart';
import 'package:frontend/models/user_details/diet_intensity.dart';
import 'package:frontend/models/user_details/diet_type.dart';
import 'package:frontend/blocs/user_details/diet_form_bloc.dart';

class DietPreferencesScreen extends StatefulWidget {
  const DietPreferencesScreen({super.key});

  @override
  State<DietPreferencesScreen> createState() => _DietPreferencesScreenState();
}

class _DietPreferencesScreenState extends State<DietPreferencesScreen> {
  bool _isFormValid = false;

  void _onFormValidityChanged(bool isValid) {
    if (isValid != _isFormValid) {
      setState(() {
        _isFormValid = isValid;
      });
    }
  }

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
      body: _DietPreferencesForm(onFormValidityChanged: _onFormValidityChanged),
      bottomNavigationBar: BottomNavBar(
        currentRoute: GoRouterState.of(context).uri.path,
        mode: NavBarMode.wizard,
        prevRoute: '/profile-details',
        nextRoute: '/calories-prediction',
        isNextRouteEnabled: _isFormValid,
      ),
    );
  }
}

class _DietPreferencesForm extends StatefulWidget {
  final ValueChanged<bool>? onFormValidityChanged;

  const _DietPreferencesForm({this.onFormValidityChanged});

  @override
  State<_DietPreferencesForm> createState() => _DietPreferencesFormState();
}

class _DietPreferencesFormState extends State<_DietPreferencesForm> {
  final _formKey = GlobalKey<FormState>();

  DietType? _selectedDietType;
  List<Allergy> _selectedAllergies = [];
  double _selectedDietGoal = 65;
  DietIntensity? _selectedDietIntensity;
  int _selectedMealsPerDay = 3;

  @override
  void initState() {
    super.initState();

    final blocState = context.read<DietFormBloc>().state;
    if (blocState is DietFormSubmit) {
      if (blocState.dietType != null) _selectedDietType = blocState.dietType;
      if (blocState.allergies != null) _selectedAllergies = blocState.allergies!;
      if (blocState.dietGoal != null) {
        _selectedDietGoal = blocState.dietGoal!;
      }
      else if(blocState.weight != null) {
        _selectedDietGoal = blocState.weight!;
        context.read<DietFormBloc>().add(UpdateDietGoal(blocState.weight!));
      }
      if (blocState.dietIntensity != null) _selectedDietIntensity = blocState.dietIntensity;
      if (blocState.mealsPerDay != null) _selectedMealsPerDay = blocState.mealsPerDay!;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) => _validateForm());
  }

  void _validateForm() {
    final isValid = _formKey.currentState?.validate() ?? false;
    final allRequiredFilled = _selectedDietType != null && _selectedDietIntensity != null && _selectedMealsPerDay > 0;

    final dietGoalValid = (_selectedDietType == DietType.weightMaintenance) || (_selectedDietGoal > 0);

    final formIsValid = isValid && allRequiredFilled && dietGoalValid;

    widget.onFormValidityChanged?.call(formIsValid);
  }

  void _onDietTypeChanged(DietType? value) {
    setState(() {
      _selectedDietType = value;
      if (_selectedDietType == DietType.weightMaintenance) {
        final state = context.read<DietFormBloc>().state;
        if (state is DietFormSubmit && state.weight != null) {
          _selectedDietGoal = state.weight!;
          context.read<DietFormBloc>().add(UpdateDietGoal(state.weight!));
        }
      }
    });
    context.read<DietFormBloc>().add(UpdateDietType(value!));
    _validateForm();
  }

  void _onAllergiesChanged(List<Allergy> values) {
    setState(() {
      _selectedAllergies = values;
    });
    context.read<DietFormBloc>().add(UpdateAllergies(values));
    _validateForm();
  }

  void _onDietGoalChanged(double value) {
    setState(() {
      _selectedDietGoal = value;
    });
    context.read<DietFormBloc>().add(UpdateDietGoal(value));
    _validateForm();
  }

  void _onMealsPerDayChanged(int value) {
    setState(() {
      _selectedMealsPerDay = value;
    });
    context.read<DietFormBloc>().add(UpdateMealsPerDay(value));
    _validateForm();
  }

  void _onDietIntensityChanged(DietIntensity? value) {
    setState(() {
      _selectedDietIntensity = value;
    });
    context.read<DietFormBloc>().add(UpdateDietIntensity(value!));
    _validateForm();
  }

  @override
  Widget build(BuildContext context) {
    final fields = [
      DropdownButtonFormField<DietType>(
        key: const Key('diet_type'),
        value: _selectedDietType,
        decoration: InputDecoration(
          labelText: AppLocalizations.of(context)!.dietType,
        ),
        items: DietType.values.map((diet) {
          return DropdownMenuItem<DietType>(
            value: diet,
            child: Text(
              AppConfig.dietTypeLabels(context)[diet]!,
              style: const TextStyle(color: Colors.black),
            ),
          );
        }).toList(),
        onChanged: _onDietTypeChanged,
        validator: (value) => validateDietType(value, context),
      ),
      MultiSelectDialogField<Allergy>(
        initialValue: _selectedAllergies,
        items: Allergy.values
            .map(
              (allergy) => MultiSelectItem<Allergy>(
                allergy,
                AppConfig.allergyLabels(context)[allergy]!,
              ),
            )
            .toList(),
        title: Text(AppLocalizations.of(context)!.allergies),
        selectedColor: Colors.purpleAccent,
        chipDisplay: MultiSelectChipDisplay(
          chipColor: Colors.purpleAccent[50],
          textStyle: const TextStyle(color: Colors.black),
        ),
        buttonText: Text(AppLocalizations.of(context)!.allergies),
        onConfirm: _onAllergiesChanged,
      ),
      if (_selectedDietType != DietType.weightMaintenance)
        WeightSlider(
          initialValue: _selectedDietGoal,
          validator: (value) => validateDietGoal(value, context),
          onChanged: _onDietGoalChanged,
          label: AppLocalizations.of(context)!.dietGoal,
          dialogTitle: AppLocalizations.of(context)!.enterYourDietGoal,
        ),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppLocalizations.of(context)!.mealsPerDay),
          const SizedBox(height: 8),
          FractionallySizedBox(
            widthFactor: 1,
            child: SegmentedButton<int>(
              segments: [
                for (var i = 1; i <= Constants.maxMealsPerDay; i++)
                  ButtonSegment(value: i, label: Text('$i')),
              ],
              selected: <int>{_selectedMealsPerDay},
              onSelectionChanged: (newSelection) {
                _onMealsPerDayChanged(newSelection.first);
              },
            ),
          ),
        ],
      ),
      const SizedBox(height: 20),
      DropdownButtonFormField<DietIntensity>(
        key: const Key('diet_intensity'),
        value: _selectedDietIntensity,
        decoration: InputDecoration(
          labelText: AppLocalizations.of(context)!.dietIntensity,
        ),
        items: DietIntensity.values.map((intensity) {
          return DropdownMenuItem<DietIntensity>(
            value: intensity,
            child: Text(
              AppConfig.dietIntensityLabels(context)[intensity]!,
              style: const TextStyle(color: Colors.black),
            ),
          );
        }).toList(),
        onChanged: _onDietIntensityChanged,
        validator: (value) => validateDietIntensity(value, context),
      ),
    ];

    return Padding(
      padding: const EdgeInsets.all(35.0),
      child: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: ListView.separated(
          shrinkWrap: true,
          itemCount: fields.length,
          separatorBuilder: (_, __) => const SizedBox(height: 20),
          itemBuilder: (_, index) => fields[index],
        ),
      ),
    );
  }
}
