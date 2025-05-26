import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/assets/calories_prediction_enums/activity_level.pb.dart';
import 'package:frontend/assets/calories_prediction_enums/sleep_quality.pb.dart';
import 'package:frontend/assets/calories_prediction_enums/stress_level.pb.dart';

import 'package:frontend/config/app_config.dart';
import 'package:frontend/events/calories_prediction_events.dart';
import 'package:frontend/models/advanced_body_parameters.dart';
import 'package:frontend/utils/calories_prediction_validators.dart';
import 'package:frontend/views/widgets/advanced_option_slider.dart';

import 'package:frontend/blocs/calories_prediction_bloc.dart';
import 'package:frontend/models/calories_prediction.dart';

class CaloriesPredictionScreen extends StatelessWidget {
  final CaloriesPredictionBloc? bloc;

  const CaloriesPredictionScreen({super.key, this.bloc});

  @override
  Widget build(BuildContext context) {
    return bloc != null
        ? BlocProvider<CaloriesPredictionBloc>.value(
          value: bloc!,
          child: _buildScaffold(),
        )
        : BlocProvider<CaloriesPredictionBloc>(
          create: (_) => CaloriesPredictionBloc(),
          child: _buildScaffold(),
        );
  }

  Widget _buildScaffold() {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            AppConfig.caloriesPrediction,
            style: AppConfig.titleStyle,
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
  final TextStyle _messageStyle = AppConfig.errorStyle;

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
        key: Key(AppConfig.activityLevel),
        value: _selectedActivityLevel,
        decoration: InputDecoration(labelText: AppConfig.activityLevel),
        items:
            ActivityLevel.values.map((activityLevel) {
              return DropdownMenuItem<ActivityLevel>(
                value: activityLevel,
                child: Text(
                  AppConfig.activityLevelLabels[activityLevel]!,
                  style: TextStyle(color: Colors.black),
                ),
              );
            }).toList(),
        onChanged: (value) {
          setState(() {
            _selectedActivityLevel = value!;
          });
        },
        validator: (value) => validateActivityLevel(value),
      ),
      DropdownButtonFormField<StressLevel>(
        key: Key(AppConfig.stressLevel),
        value: _selectedStressLevel,
        decoration: InputDecoration(labelText: AppConfig.stressLevel),
        items:
            StressLevel.values.map((stressLevel) {
              return DropdownMenuItem<StressLevel>(
                value: stressLevel,
                child: Text(
                  AppConfig.stressLevelLabels[stressLevel]!,
                  style: TextStyle(color: Colors.black),
                ),
              );
            }).toList(),
        onChanged: (value) {
          setState(() {
            _selectedStressLevel = value!;
          });
        },
        validator: (value) => validateStressLevel(value),
      ),
      DropdownButtonFormField<SleepQuality>(
        key: Key(AppConfig.sleepQuality),
        value: _selectedSleepQuality,
        decoration: InputDecoration(labelText: AppConfig.sleepQuality),
        items:
            SleepQuality.values.map((sleepQuality) {
              return DropdownMenuItem<SleepQuality>(
                value: sleepQuality,
                child: Text(
                  AppConfig.sleepQualityLabels[sleepQuality]!,
                  style: TextStyle(color: Colors.black),
                ),
              );
            }).toList(),
        onChanged: (value) {
          setState(() {
            _selectedSleepQuality = value!;
          });
        },
        validator: (value) => validateSleepQuality(value),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0),
        child: CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(AppConfig.advancedBodyParameters),
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
          propertiesName: AppConfig.musclePercentage,
          alertDialogTitle: AppConfig.enterMusclePercentage,
          inputDecorator: AppConfig.musclePercentage,
          validator: (value) => validateMusclePercentage(value),
          onChanged: (value) {
            setState(() {
              _selectedMusclePercentage = value;
            });
          },
        ),
        PercentageOptionSlider(
          initialValue: _selectedWaterPercentage,
          propertiesName: AppConfig.waterPercentage,
          alertDialogTitle: AppConfig.enterWaterPercentage,
          inputDecorator: AppConfig.waterPercentage,
          validator: (value) => validateWaterPercentage(value),
          onChanged: (value) {
            setState(() {
              _selectedWaterPercentage = value;
            });
          },
        ),
        PercentageOptionSlider(
          initialValue: _selectedFatPercentage,
          propertiesName: AppConfig.fatPercentage,
          alertDialogTitle: AppConfig.enterFatPercentage,
          inputDecorator: AppConfig.fatPercentage,
          validator: (value) => validateFatPercentage(value),
          onChanged: (value) {
            setState(() {
              _selectedFatPercentage = value;
            });
          },
        ),
      ],
      SizedBox(height: 16),
      ElevatedButton(
        key: Key(AppConfig.generateWeeklyDiet),
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
        child: Text(AppConfig.generateWeeklyDiet),
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
          key: Key(AppConfig.caloriesPrediction),
          shrinkWrap: true,
          itemCount: fields.length,
          separatorBuilder: (_, __) => SizedBox(height: 20),
          itemBuilder: (_, index) => fields[index],
        ),
      ),
    );
  }
}
