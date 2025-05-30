import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:frontend/config/app_config.dart';
import 'package:frontend/config/styles.dart';
import 'package:frontend/events/user_details/calories_prediction_events.dart';
import 'package:frontend/models/user_details/advanced_body_parameters.dart';
import 'package:frontend/utils/user_details/calories_prediction_validators.dart';
import 'package:frontend/views/widgets/advanced_option_slider.dart';
import 'package:frontend/blocs/user_details/calories_prediction_bloc.dart';
import 'package:frontend/models/user_details/calories_prediction.dart';
import 'package:frontend/l10n/app_localizations.dart';
import 'package:frontend/models/user_details/activity_level.dart';
import 'package:frontend/models/user_details/sleep_quality.dart';
import 'package:frontend/models/user_details/stress_level.dart';

class CaloriesPredictionScreen extends StatelessWidget {
  final CaloriesPredictionBloc? bloc;

  const CaloriesPredictionScreen({super.key, this.bloc});

  @override
  Widget build(BuildContext context) {
    return bloc != null
        ? BlocProvider<CaloriesPredictionBloc>.value(
          value: bloc!,
          child: _buildScaffold(context),
        )
        : BlocProvider<CaloriesPredictionBloc>(
          create: (_) => CaloriesPredictionBloc(),
          child: _buildScaffold(context),
        );
  }

  Widget _buildScaffold(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            AppLocalizations.of(context)!.caloriesPrediction,
            style: Styles.titleStyle,
          ),
        ),
      ),
      body: _CaloriesPredictionForm(),
    );
  }
}

class _CaloriesPredictionForm extends StatefulWidget {
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
  double _selectedMusclePercentage = 45.0;
  double _selectedWaterPercentage = 60.0;
  double _selectedFatPercentage = 15.0;
  String? _message;
  final TextStyle _messageStyle = Styles.errorStyle;

  @override
  void initState() {
    super.initState();
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
        },
        validator: (value) => validateActivityLevel(value, context),
      ),
      DropdownButtonFormField<StressLevel>(
        key: Key('stress_level'),
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
        },
        validator: (value) => validateStressLevel(value, context),
      ),
      DropdownButtonFormField<SleepQuality>(
        key: Key('sleep_quality'),
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
            });
          },
          controlAffinity: ListTileControlAffinity.leading,
        ),
      ),
      if (_isChecked) ...[
        PercentageOptionSlider(
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
          },
        ),
        PercentageOptionSlider(
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
          },
        ),
        PercentageOptionSlider(
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
          },
        ),
      ],
      SizedBox(height: 16),
      ElevatedButton(
        key: Key(AppLocalizations.of(context)!.generateWeeklyDiet),
        onPressed: () {
          AdvancedBodyParameters? advancedBodyParameters;
          if (_isChecked) {
            advancedBodyParameters = AdvancedBodyParameters(
              musclePercentage: _selectedMusclePercentage,
              waterPercentage: _selectedWaterPercentage,
              fatPercentage: _selectedFatPercentage,
            );
          }
          CaloriesPrediction caloriesPrediction = CaloriesPrediction(
            activityLevel: _selectedActivityLevel!,
            stressLevel: _selectedStressLevel!,
            sleepQuality: _selectedSleepQuality!,
            advancedBodyParametersEnabled: _isChecked,
            advancedBodyParameters: advancedBodyParameters,
          );
          context.read<CaloriesPredictionBloc>().add(
            CaloriesPredictionSubmitted(caloriesPrediction),
          );
        },
        style: ElevatedButton.styleFrom(backgroundColor: Color(0xFFB2F2BB)),
        child: Text(AppLocalizations.of(context)!.generateWeeklyDiet),
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
          key: Key(AppLocalizations.of(context)!.caloriesPrediction),
          shrinkWrap: true,
          itemCount: fields.length,
          separatorBuilder: (_, __) => SizedBox(height: 20),
          itemBuilder: (_, index) => fields[index],
        ),
      ),
    );
  }
}
