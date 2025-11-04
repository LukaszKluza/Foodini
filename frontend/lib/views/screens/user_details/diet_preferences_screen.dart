import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/blocs/user_details/diet_form_bloc.dart';
import 'package:frontend/config/app_config.dart';
import 'package:frontend/config/constants.dart';
import 'package:frontend/config/styles.dart';
import 'package:frontend/events/user_details/diet_form_events.dart';
import 'package:frontend/l10n/app_localizations.dart';
import 'package:frontend/models/user_details/diet_intensity.dart';
import 'package:frontend/models/user_details/diet_type.dart';
import 'package:frontend/models/user_details/dietary_restriction.dart';
import 'package:frontend/states/diet_form_states.dart';
import 'package:frontend/utils/user_details/diet_preferences_validators.dart';
import 'package:frontend/views/widgets/bottom_nav_bar.dart';
import 'package:frontend/views/widgets/title_text.dart';
import 'package:frontend/views/widgets/weight_slider.dart';
import 'package:go_router/go_router.dart';
import 'package:multi_select_flutter/chip_display/multi_select_chip_display.dart';
import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';

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
        automaticallyImplyLeading: false,
        title: Center(
          child: TitleTextWidgets.scaledTitle(AppLocalizations.of(context)!.dietPreferences),
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
  List<DietaryRestriction> _selectedDietaryRestrictions = [];
  double _selectedDietGoal = Constants.defaultWeight;
  DietIntensity? _selectedDietIntensity;
  int _selectedMealsPerDay = Constants.defaultMealsPerDay;
  double _selectedWeight = Constants.defaultWeight;

  String? _dietGoalError;

  @override
  void initState() {
    super.initState();

    final blocState = context.read<DietFormBloc>().state;
    if (blocState is DietFormSubmit) {
      _selectedDietType = blocState.dietType ?? _selectedDietType;
      _selectedDietGoal = blocState.dietGoal ?? _selectedDietGoal;
      _selectedDietaryRestrictions = blocState.dietaryRestrictions ?? _selectedDietaryRestrictions;
      _selectedDietIntensity =
          blocState.dietIntensity ?? _selectedDietIntensity;
      _selectedMealsPerDay = blocState.mealsPerDay ?? _selectedMealsPerDay;
      _selectedWeight = blocState.weight!;

      if (_selectedDietType == DietType.weightMaintenance ||
          (_selectedDietType == DietType.muscleGain &&
              _selectedDietGoal < _selectedWeight) ||
          (_selectedDietType == DietType.fatLoss &&
              _selectedDietGoal > _selectedWeight) ||
          _selectedDietType == null) {
        _selectedDietGoal = _selectedWeight;
        context.read<DietFormBloc>().add(UpdateDietGoal(_selectedDietGoal));
      }
    }

    WidgetsBinding.instance.addPostFrameCallback((_) => _softFormValidation());
  }

  void _softFormValidation() {
    final allRequiredFilled =
        _selectedDietType != null &&
        _selectedDietIntensity != null &&
        _selectedMealsPerDay >= Constants.minMealsPerDay &&
          _selectedMealsPerDay <= Constants.maxMealsPerDay;

    final error = validateDietGoal(
      _selectedDietGoal.toString(),
      context,
      dietType: _selectedDietType,
      weight: _selectedWeight,
    );

    setState(() {
      _dietGoalError = error;
    });

    final dietGoalValid = error == null;

    widget.onFormValidityChanged?.call(allRequiredFilled && dietGoalValid);
  }

  void _updateStateAndBloc<T>({
    required void Function() updateState,
    required DietFormEvent blocEvent,
  }) {
    setState(updateState);
    context.read<DietFormBloc>().add(blocEvent);
    _softFormValidation();
  }

  void _onDietTypeChanged(DietType? value) {
    _updateStateAndBloc(
      updateState: () {
        _selectedDietType = value;
        if (_selectedDietType == DietType.weightMaintenance) {
          final state = context.read<DietFormBloc>().state;
          if (state is DietFormSubmit && state.weight != null) {
            _selectedDietGoal = state.weight!;
            context.read<DietFormBloc>().add(UpdateDietGoal(state.weight!));
          }
        }
      },
      blocEvent: UpdateDietType(value!),
    );
  }

  void _onDietaryRestrictionsChanged(List<DietaryRestriction> values) {
    _updateStateAndBloc(
      updateState: () => _selectedDietaryRestrictions = values,
      blocEvent: UpdateDietaryRestrictions(values),
    );
  }

  void _onDietGoalChanged(double value) {
    _updateStateAndBloc(
      updateState: () => _selectedDietGoal = value,
      blocEvent: UpdateDietGoal(value),
    );
  }

  void _onMealsPerDayChanged(int value) {
    _updateStateAndBloc(
      updateState: () => _selectedMealsPerDay = value,
      blocEvent: UpdateMealsPerDay(value),
    );
  }

  void _onDietIntensityChanged(DietIntensity? value) {
    _updateStateAndBloc(
      updateState: () => _selectedDietIntensity = value,
      blocEvent: UpdateDietIntensity(value!),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    final fields = [
      DropdownButtonFormField<DietType>(
        key: const Key('diet_type'),
        isExpanded: true,
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
                  style: const TextStyle(color: Colors.black),
                ),
              );
            }).toList(),
        onChanged: _onDietTypeChanged,
        validator: (value) => validateDietType(value, context),
      ),
      MultiSelectDialogField<DietaryRestriction>(
        initialValue: _selectedDietaryRestrictions,
        items:
            DietaryRestriction.values
                .map(
                  (dietaryRestriction) => MultiSelectItem<DietaryRestriction>(
                    dietaryRestriction,
                    AppConfig.dietaryRestrictionLabels(context)[dietaryRestriction]!,
                  ),
                )
                .toList(),
        title: Text(AppLocalizations.of(context)!.dietaryRestrictions),
        selectedColor: Colors.purpleAccent,
        chipDisplay: MultiSelectChipDisplay(
          chipColor: Colors.purpleAccent[50],
          textStyle: const TextStyle(color: Colors.black),
        ),
        buttonText: Text(AppLocalizations.of(context)!.dietaryRestrictions),
        onConfirm: _onDietaryRestrictionsChanged,
      ),
      if (_selectedDietType != DietType.weightMaintenance)
        WeightSlider(
          value: _selectedDietGoal,
          onChanged: _onDietGoalChanged,
          label: AppLocalizations.of(context)!.dietGoal,
          dialogTitle: AppLocalizations.of(context)!.enterYourDietGoal,
        ),
      if (_dietGoalError != null)
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(_dietGoalError!, style: Styles.errorStyle),
        ),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppLocalizations.of(context)!.mealsPerDay),
          const SizedBox(height: 8),
          FractionallySizedBox(
            widthFactor: 1,
            child: SegmentedButton<int>(
              showSelectedIcon: true,
              style: ButtonStyle(
                  iconSize: WidgetStateProperty.all(min(screenWidth * 0.06, 30)),
                  padding: WidgetStateProperty.all(
                      EdgeInsets.symmetric(horizontal: 0, vertical: 0))
              ),
              segments: [
                for (var i = Constants.minMealsPerDay; i <= Constants.maxMealsPerDay; i++)
                  ButtonSegment(
                      value: i,
                      label: Text('$i', style: TextStyle(
                          fontSize: min(screenWidth * 0.04, 20)))
                  ),
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
        isExpanded: true,
        value: _selectedDietIntensity,
        decoration: InputDecoration(
          labelText: AppLocalizations.of(context)!.dietIntensity,
        ),
        items:
            DietIntensity.values.map((intensity) {
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
