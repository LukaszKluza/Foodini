import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/blocs/diet_preferences_bloc.dart';
import 'package:frontend/config/app_config.dart';
import 'package:frontend/utils/user_validators.dart';

class DietPreferencesScreen extends StatelessWidget {
  final DietPreferencesBloc? bloc;

  const DietPreferencesScreen({super.key, this.bloc});

  @override
  Widget build(BuildContext context) {
    return bloc != null
        ? BlocProvider<DietPreferencesBloc>.value(
      value: bloc!,
      child: _buildScaffold(),
    )
        : BlocProvider<DietPreferencesBloc>(
      create: (_) => DietPreferencesBloc(),
      child: _buildScaffold(),
    );
  }

  Widget _buildScaffold() {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(AppConfig.dietPreferences, style: AppConfig.titleStyle),
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
  final TextEditingController _dietIntensityController = TextEditingController();

  String? _message;
  TextStyle _messageStyle = AppConfig.errorStyle;

  @override
  void initState() {
    super.initState();
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
      TextFormField(
        key: Key(AppConfig.dietType),
        controller: _dietTypeController,
        decoration: InputDecoration(labelText: AppConfig.dietType),
        keyboardType: TextInputType.text,
        validator: validateEmail,
      ),
      TextFormField(
        key: Key(AppConfig.allergies),
        controller: _allergiesController,
        decoration: InputDecoration(labelText: AppConfig.allergies),
        obscureText: true,
        validator: validatePassword,
      ),
      TextFormField(
        key: Key(AppConfig.dietGoal),
        controller: _dietGoalController,
        decoration: InputDecoration(labelText: AppConfig.dietGoal),
        obscureText: true,
        validator: validatePassword,
      ),
      TextFormField(
        key: Key(AppConfig.mealsPerDay),
        controller: _mealsPerDeyController,
        decoration: InputDecoration(labelText: AppConfig.mealsPerDay),
        obscureText: true,
        validator: validatePassword,
      ),
      TextFormField(
        key: Key(AppConfig.dietIntensity),
        controller: _dietIntensityController,
        decoration: InputDecoration(labelText: AppConfig.dietIntensity),
        obscureText: true,
        validator: validatePassword,
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
