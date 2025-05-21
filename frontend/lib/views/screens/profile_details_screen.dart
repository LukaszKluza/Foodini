import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/blocs/profile_details_bloc.dart';
import 'package:frontend/config/app_config.dart';
import 'package:frontend/utils/user_validators.dart';

class ProfileDetailsScreen extends StatelessWidget {
  final ProfileDetailsBlock? bloc;

  const ProfileDetailsScreen({super.key, this.bloc});

  @override
  Widget build(BuildContext context) {
    return bloc != null
        ? BlocProvider<ProfileDetailsBlock>.value(
      value: bloc!,
      child: _buildScaffold(),
    )
        : BlocProvider<ProfileDetailsBlock>(
      create: (_) => ProfileDetailsBlock(),
      child: _buildScaffold(),
    );
  }

  Widget _buildScaffold() {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(AppConfig.profileDetails, style: AppConfig.titleStyle),
        ),
      ),
      body: _ProfileDetailsForm(),
    );
  }
}

class _ProfileDetailsForm extends StatefulWidget {
  @override
  State<_ProfileDetailsForm> createState() => _ProfileDetailsFormState();
}

class _ProfileDetailsFormState extends State<_ProfileDetailsForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _dateOfBirthController = TextEditingController();

  String? _message;
  TextStyle _messageStyle = AppConfig.errorStyle;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _genderController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _dateOfBirthController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fields = [
      TextFormField(
        key: Key(AppConfig.gender),
        controller: _genderController,
        decoration: InputDecoration(labelText: AppConfig.gender),
        keyboardType: TextInputType.text,
        validator: validateEmail,
      ),
      TextFormField(
        key: Key(AppConfig.height),
        controller: _heightController,
        decoration: InputDecoration(labelText: AppConfig.height),
        obscureText: true,
        validator: validatePassword,
      ),
      TextFormField(
        key: Key(AppConfig.weight),
        controller: _weightController,
        decoration: InputDecoration(labelText: AppConfig.weight),
        obscureText: true,
        validator: validatePassword,
      ),
      TextFormField(
        key: Key(AppConfig.dateOfBirth),
        controller: _dateOfBirthController,
        decoration: InputDecoration(labelText: AppConfig.dateOfBirth),
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
          separatorBuilder: (_, _) => SizedBox(height: 20),
          itemBuilder: (_, index) => fields[index],
        ),
      ),
    );
  }
}