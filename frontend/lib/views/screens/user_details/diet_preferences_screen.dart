import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/blocs/user_details/diet_form_bloc.dart';
import 'package:frontend/config/app_config.dart';
import 'package:frontend/config/constants.dart';
import 'package:frontend/config/styles.dart';
import 'package:frontend/events/user_details/diet_form_events.dart';
import 'package:frontend/l10n/app_localizations.dart';
import 'package:frontend/models/user_details/cooking_skills.dart';
import 'package:frontend/models/user_details/daily_budget.dart';
import 'package:frontend/models/user_details/diet_intensity.dart';
import 'package:frontend/models/user_details/diet_style.dart';
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

  List<Allergies> _selectedAllergies = [];
  DietType? _selectedDietType;
  DietStyle? _selectedDietStyle;
  double _selectedDietGoal = Constants.defaultWeight;
  DietIntensity? _selectedDietIntensity;
  int _selectedMealsPerDay = Constants.defaultMealsPerDay;
  double _selectedWeight = Constants.defaultWeight;
  DailyBudget? _selectedDailyBudget = Constants.defaultDailyBudget;
  CookingSkills? _selectedCookingSkills = Constants.defaultCookingSkills;

  String? _dietGoalError;

  @override
  void initState() {
    super.initState();

    final blocState = context.read<DietFormBloc>().state;
    if (blocState is DietFormSubmit) {
      _selectedDietType = blocState.dietType ?? _selectedDietType;
      _selectedDietStyle = blocState.dietStyle ?? _selectedDietStyle;
      _selectedDietGoal = blocState.dietGoal ?? _selectedDietGoal;
      _selectedAllergies = blocState.allergies ?? _selectedAllergies;
      _selectedDietIntensity =
          blocState.dietIntensity ?? _selectedDietIntensity;
      _selectedMealsPerDay = blocState.mealsPerDay ?? _selectedMealsPerDay;
      _selectedDailyBudget = blocState.dailyBudget ?? _selectedDailyBudget;
      _selectedCookingSkills = blocState.cookingSkills ?? _selectedCookingSkills;
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
            _selectedMealsPerDay <= Constants.maxMealsPerDay &&
            _selectedDailyBudget != null &&
            _selectedCookingSkills != null;

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

  void _onDietStyleChanged(DietStyle? value) {
    _updateStateAndBloc(
      updateState: () => _selectedDietStyle = value,
      blocEvent: UpdateDietStyle(value),
    );
  }

  void _onAllergiesChanged(List<Allergies> values) {
    _updateStateAndBloc(
      updateState: () => _selectedAllergies = values,
      blocEvent: UpdateAllergies(values),
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

  void _onDailyBudgetChanged(DailyBudget? value) {
    _updateStateAndBloc(
      updateState: () => _selectedDailyBudget = value,
      blocEvent: UpdateDailyBudget(value!),
    );
  }

  void _onCookingSkillsChanged(CookingSkills? value) {
    _updateStateAndBloc(
      updateState: () => _selectedCookingSkills = value,
      blocEvent: UpdateCookingSkills(value!),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    final fields = [
      MultiSelectDialogField<Allergies>(
        initialValue: _selectedAllergies,
        items:
            Allergies.values
                .map(
                  (allergy) => MultiSelectItem<Allergies>(
                    allergy,
                    AppConfig.allergiesLabels(context)[allergy]!,
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
      DropdownButtonFormField<DietStyle>(
        key: const Key('diet_style'),
        isExpanded: true,
        initialValue: _selectedDietStyle,
        decoration: InputDecoration(
          labelText: AppLocalizations.of(context)!.dietStyle,
        ),
        items: [
          for (final dietStyle in [null, ...DietStyle.values])
            DropdownMenuItem<DietStyle>(
              value: dietStyle,
              child: Text(
                dietStyle == null
                    ? AppLocalizations.of(context)!.chooseOption
                    : AppConfig.dietStyleLabels(context)[dietStyle]!,
              ),
            ),
        ],
        onChanged: _onDietStyleChanged,
      ),
      DropdownButtonFormField<DietType>(
        key: const Key('diet_type'),
        isExpanded: true,
        initialValue: _selectedDietType,
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
      if (_selectedDietType != DietType.weightMaintenance)
        WeightSlider(
          value: _selectedDietGoal,
          onChanged: _onDietGoalChanged,
          label: AppLocalizations.of(context)!.dietGoal,
          dialogTitle: AppLocalizations.of(context)!.enterYourDietGoal,
        ),
      if (_dietGoalError != null)
          Text(_dietGoalError!, style: Styles.errorStyle),
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
      Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<DailyBudget>(
              isExpanded: true,
              initialValue: _selectedDailyBudget,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.dailyBudget,
              ),
              items: DailyBudget.values.map((dailyBudgetValue) {
                return DropdownMenuItem<DailyBudget>(
                  value: dailyBudgetValue,
                  child: Text(
                    AppConfig.dailyBudgetLabels(context)[dailyBudgetValue]!,
                    style: const TextStyle(color: Colors.black),
                  ),
                );
              }).toList(),
              onChanged: _onDailyBudgetChanged,
              validator: (value) => validateDailyBudget(value, context),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: DropdownButtonFormField<CookingSkills>(
              isExpanded: true,
              initialValue: _selectedCookingSkills,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.cookingSkills,
              ),
              items: CookingSkills.values.map((cookingSkillsValue) {
                return DropdownMenuItem<CookingSkills>(
                  value: cookingSkillsValue,
                  child: Text(
                    AppConfig.cookingSkillsLabels(context)[cookingSkillsValue]!,
                    style: const TextStyle(color: Colors.black),
                  ),
                );
              }).toList(),
              onChanged: _onCookingSkillsChanged,
              validator: (value) => validateCookingSkill(value, context),
            ),
          ),
        ],
      ),
      DropdownButtonFormField<DietIntensity>(
        key: const Key('diet_intensity'),
        isExpanded: true,
        initialValue: _selectedDietIntensity,
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
      padding: const EdgeInsets.fromLTRB(35.0, 15.0, 35.0, 35.0),
      child: Form(
        key: _formKey,
        child: ListView.separated(
          shrinkWrap: true,
          itemCount: fields.length,
          separatorBuilder: (_, _) => const SizedBox(height: 15),
          itemBuilder: (_, index) => fields[index],
        ),
      ),
    );
  }
}
