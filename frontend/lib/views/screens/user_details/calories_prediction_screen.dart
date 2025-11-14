import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/blocs/user_details/diet_form_bloc.dart';
import 'package:frontend/config/app_config.dart';
import 'package:frontend/config/constants.dart';
import 'package:frontend/config/styles.dart';
import 'package:frontend/events/user_details/diet_form_events.dart';
import 'package:frontend/l10n/app_localizations.dart';
import 'package:frontend/listeners/user_details/diet_form_listener.dart';
import 'package:frontend/models/user_details/activity_level.dart';
import 'package:frontend/models/user_details/sleep_quality.dart';
import 'package:frontend/models/user_details/stress_level.dart';
import 'package:frontend/states/diet_form_states.dart';
import 'package:frontend/utils/user_details/calories_prediction_validators.dart';
import 'package:frontend/views/widgets/advanced_option_slider.dart';
import 'package:frontend/views/widgets/bottom_nav_bar.dart';
import 'package:frontend/views/widgets/title_text.dart';
import 'package:go_router/go_router.dart';

class CaloriesPredictionScreen extends StatelessWidget {
  const CaloriesPredictionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: TitleTextWidgets.scaledTitle(
            AppLocalizations.of(context)!.caloriesPrediction,
            longText: true,
          ),
        ),
      ),
      body: _CaloriesPredictionForm(),
      bottomNavigationBar: BottomNavBar(
        currentRoute: GoRouterState.of(context).uri.path,
        mode: NavBarMode.wizard,
        prevRoute: '/diet-preferences',
      ),
    );
  }
}

class _CaloriesPredictionForm extends StatefulWidget {
  const _CaloriesPredictionForm();

  @override
  State<_CaloriesPredictionForm> createState() =>
      _CaloriesPredictionFormState();
}

class _CaloriesPredictionFormState extends State<_CaloriesPredictionForm> {
  final _formKey = GlobalKey<FormState>();
  bool _isChecked = false;
  final TextEditingController _activityLevelController =
      TextEditingController();
  final TextEditingController _stressLevelController = TextEditingController();
  final TextEditingController _sleepQualityController = TextEditingController();

  ActivityLevel? _selectedActivityLevel;
  StressLevel? _selectedStressLevel;
  SleepQuality? _selectedSleepQuality;
  double _selectedMusclePercentage = Constants.defaultMusclePercentage;
  double _selectedWaterPercentage = Constants.defaultWaterPercentage;
  double _selectedFatPercentage = Constants.defaultFatPercentage;
  String? _message;
  TextStyle _messageStyle = Styles.errorStyle;

  @override
  void initState() {
    super.initState();

    final blocState = context.read<DietFormBloc>().state;
    if (blocState is DietFormSubmit) {
      _selectedActivityLevel =
          blocState.activityLevel ?? _selectedActivityLevel;
      _selectedStressLevel = blocState.stressLevel ?? _selectedStressLevel;
      _selectedSleepQuality = blocState.sleepQuality ?? _selectedSleepQuality;
      _selectedMusclePercentage =
          blocState.musclePercentage ?? _selectedMusclePercentage;
      _selectedWaterPercentage =
          blocState.waterPercentage ?? _selectedWaterPercentage;
      _selectedFatPercentage =
          blocState.fatPercentage ?? _selectedFatPercentage;
      if (blocState.musclePercentage != null ||
          blocState.waterPercentage != null ||
          blocState.fatPercentage != null) {
        _isChecked = true;
      }
    }
  }

  @override
  void dispose() {
    _activityLevelController.dispose();
    _stressLevelController.dispose();
    _sleepQualityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fields = [
      DropdownButtonFormField<ActivityLevel>(
        key: Key('activity_level'),
        isExpanded: true,
        value: _selectedActivityLevel,
        decoration: InputDecoration(
          labelText: AppLocalizations.of(context)!.activityLevel,
        ),
        items:
            ActivityLevel.values.map((activityLevel) {
              return DropdownMenuItem<ActivityLevel>(
                value: activityLevel,
                child: Text(
                  AppConfig.activityLevelLabels(context)[activityLevel]!,
                  style: TextStyle(color: Colors.black),
                ),
              );
            }).toList(),
        onChanged: (value) {
          setState(() {
            _selectedActivityLevel = value!;
          });
          context.read<DietFormBloc>().add(UpdateActivityLevel(value!));
        },
        validator: (value) => validateActivityLevel(value, context),
      ),
      DropdownButtonFormField<StressLevel>(
        key: Key('stress_level'),
        isExpanded: true,
        value: _selectedStressLevel,
        decoration: InputDecoration(
          labelText: AppLocalizations.of(context)!.stressLevel,
        ),
        items:
            StressLevel.values.map((stressLevel) {
              return DropdownMenuItem<StressLevel>(
                value: stressLevel,
                child: Text(
                  AppConfig.stressLevelLabels(context)[stressLevel]!,
                  style: TextStyle(color: Colors.black),
                ),
              );
            }).toList(),
        onChanged: (value) {
          setState(() {
            _selectedStressLevel = value!;
          });
          context.read<DietFormBloc>().add(UpdateStressLevel(value!));
        },
        validator: (value) => validateStressLevel(value, context),
      ),
      DropdownButtonFormField<SleepQuality>(
        key: Key('sleep_quality'),
        isExpanded: true,
        value: _selectedSleepQuality,
        decoration: InputDecoration(
          labelText: AppLocalizations.of(context)!.sleepQuality,
        ),
        items:
            SleepQuality.values.map((sleepQuality) {
              return DropdownMenuItem<SleepQuality>(
                value: sleepQuality,
                child: Text(
                  AppConfig.sleepQualityLabels(context)[sleepQuality]!,
                  style: TextStyle(color: Colors.black),
                ),
              );
            }).toList(),
        onChanged: (value) {
          setState(() {
            _selectedSleepQuality = value!;
          });
          context.read<DietFormBloc>().add(UpdateSleepQuality(value!));
        },
        validator: (value) => validateSleepQuality(value, context),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0),
        child: CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(AppLocalizations.of(context)!.advancedBodyParameters),
          value: _isChecked,
          onChanged: (value) {
            setState(() {
              _isChecked = value!;
              if (_isChecked) {
                context.read<DietFormBloc>().add(
                  UpdateAdvancedParameters(
                    musclePercentage: _selectedMusclePercentage,
                    waterPercentage: _selectedWaterPercentage,
                    fatPercentage: _selectedFatPercentage,
                  ),
                );
              } else {
                _selectedMusclePercentage = Constants.defaultMusclePercentage;
                _selectedWaterPercentage = Constants.defaultWaterPercentage;
                _selectedFatPercentage = Constants.defaultFatPercentage;
                context.read<DietFormBloc>().add(
                  UpdateAdvancedParameters(
                    musclePercentage: null,
                    waterPercentage: null,
                    fatPercentage: null,
                  ),
                );
              }
            });
          },
          controlAffinity: ListTileControlAffinity.leading,
        ),
      ),
      if (_isChecked) ...[
        PercentageOptionSlider(
          min: Constants.minimumMusclePercentage,
          max: Constants.maximumMusclePercentage,
          initialValue: _selectedMusclePercentage,
          pupUpKey: 'muscle_percentage',
          propertiesName: AppLocalizations.of(context)!.musclePercentage,
          alertDialogTitle: AppLocalizations.of(context)!.enterMusclePercentage,
          inputDecorator: AppLocalizations.of(context)!.musclePercentage,
          validator: (value) => validateMusclePercentage(value, context),
          onChanged: (value) {
            setState(() {
              _selectedMusclePercentage = value;
            });
            context.read<DietFormBloc>().add(
              UpdateAdvancedParameters(
                musclePercentage: _selectedMusclePercentage,
                waterPercentage: _selectedWaterPercentage,
                fatPercentage: _selectedFatPercentage,
              ),
            );
          },
        ),
        PercentageOptionSlider(
          min: Constants.minimumWaterPercentage,
          max: Constants.maximumWaterPercentage,
          initialValue: _selectedWaterPercentage,
          pupUpKey: 'water_percentage',
          propertiesName: AppLocalizations.of(context)!.waterPercentage,
          alertDialogTitle: AppLocalizations.of(context)!.enterWaterPercentage,
          inputDecorator: AppLocalizations.of(context)!.waterPercentage,
          validator: (value) => validateWaterPercentage(value, context),
          onChanged: (value) {
            setState(() {
              _selectedWaterPercentage = value;
            });
            context.read<DietFormBloc>().add(
              UpdateAdvancedParameters(
                musclePercentage: _selectedMusclePercentage,
                waterPercentage: _selectedWaterPercentage,
                fatPercentage: _selectedFatPercentage,
              ),
            );
          },
        ),
        PercentageOptionSlider(
          min: Constants.minimumFatPercentage,
          max: Constants.maximumFatPercentage,
          initialValue: _selectedFatPercentage,
          pupUpKey: 'fat_percentage',
          propertiesName: AppLocalizations.of(context)!.fatPercentage,
          alertDialogTitle: AppLocalizations.of(context)!.enterFatPercentage,
          inputDecorator: AppLocalizations.of(context)!.fatPercentage,
          validator: (value) => validateFatPercentage(value, context),
          onChanged: (value) {
            setState(() {
              _selectedFatPercentage = value;
            });
            context.read<DietFormBloc>().add(
              UpdateAdvancedParameters(
                musclePercentage: _selectedMusclePercentage,
                waterPercentage: _selectedWaterPercentage,
                fatPercentage: _selectedFatPercentage,
              ),
            );
          },
        ),
      ],
      SizedBox(height: 16),
    ];

    return Padding(
      padding: EdgeInsets.all(35.0),
      child: BlocConsumer<DietFormBloc, DietFormState>(
        listener: (context, state) {
          DietFormListenerHelper.onDietFormSubmitListener(
            context: context,
            state: state,
            mounted: mounted,
            setMessage: (msg) => _message = msg,
            setMessageStyle: (style) => _messageStyle = style,
          );
        },
        builder: (context, state) {
          return Form(
            key: _formKey,
            child: ListView(
              shrinkWrap: true,
              children: [
                ...fields,
                if (state is DietFormSubmit && state.isSubmitting)
                  const Center(child: CircularProgressIndicator())
                else
                  ElevatedButton(
                    key: Key(AppLocalizations.of(context)!.generateWeeklyDiet),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        context.read<DietFormBloc>().add(SubmitForm());
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFB2F2BB),
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.generateWeeklyDiet,
                    ),
                  ),
                if (_message != null)
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(_message!, style: _messageStyle),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
