import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/listeners/register_listener.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:frontend/blocs/register_bloc.dart';
import 'package:frontend/config/app_config.dart';
import 'package:frontend/events/register_events.dart';
import 'package:frontend/models/register_request.dart';
import 'package:frontend/repository/auth_repository.dart';
import 'package:frontend/states/register_states.dart';
import 'package:frontend/utils/user_validators.dart';

class RegisterScreen extends StatelessWidget {
  final RegisterBloc? bloc;

  const RegisterScreen({super.key, this.bloc});

  @override
  Widget build(BuildContext context) {
    return bloc != null
        ? BlocProvider<RegisterBloc>.value(
          value: bloc!,
          child: _buildScaffold(),
        )
        : BlocProvider<RegisterBloc>(
          create:
              (_) => RegisterBloc(
                Provider.of<AuthRepository>(context, listen: false),
              ),
          child: _buildScaffold(),
        );
  }

  Widget _buildScaffold() {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(AppConfig.registration, style: AppConfig.titleStyle),
        ),
      ),
      body: _RegisterForm(),
    );
  }
}

class _RegisterForm extends StatefulWidget {
  @override
  State<_RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<_RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  String? _selectedCountry;
  String? _message;
  TextStyle _messageStyle = AppConfig.errorStyle;

  void _pickCountry(BuildContext context) {
    showCountryPicker(
      context: context,
      showPhoneCode: false,
      onSelect: (Country country) {
        setState(() {
          _selectedCountry = country.name;
          _countryController.text = _selectedCountry ?? '';
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(35.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                key: Key(AppConfig.firstName),
                controller: _firstNameController,
                decoration: InputDecoration(labelText: AppConfig.firstName),
                validator: (value) => validateName(value),
              ),
              TextFormField(
                key: Key(AppConfig.lastName),
                controller: _lastNameController,
                decoration: InputDecoration(labelText: AppConfig.lastName),
                validator: (value) => validateName(value),
              ),
              TextFormField(
                key: Key(AppConfig.country),
                readOnly: true,
                decoration: InputDecoration(labelText: AppConfig.country),
                controller: _countryController,
                onTap: () => _pickCountry(context),
                validator: (value) => validateCountry(value),
              ),
              TextFormField(
                key: Key(AppConfig.email),
                controller: _emailController,
                decoration: InputDecoration(labelText: AppConfig.email),
                keyboardType: TextInputType.emailAddress,
                validator: validateEmail,
              ),
              TextFormField(
                key: Key(AppConfig.password),
                controller: _passwordController,
                decoration: InputDecoration(labelText: AppConfig.password),
                obscureText: true,
                validator: validatePassword,
              ),
              TextFormField(
                key: Key(AppConfig.confirmPassword),
                controller: _confirmPasswordController,
                decoration: InputDecoration(
                  labelText: AppConfig.confirmPassword,
                ),
                obscureText: true,
                validator:
                    (value) => validateConfirmPassword(
                      value,
                      _passwordController.text,
                    ),
              ),
              SizedBox(height: 20),
              BlocConsumer<RegisterBloc, RegisterState>(
                listener: (context, state) {
                  RegisterListenerHelper.onChangePasswordListener(
                    context: context,
                    state: state,
                    setState: setState,
                    mounted: mounted,
                    setMessage: (msg) => _message = msg,
                    setMessageStyle: (style) => _messageStyle = style,
                  );
                },
                builder: (context, state) {
                  if (state is RegisterLoading) {
                    return CircularProgressIndicator();
                  } else {
                    return ElevatedButton(
                      key: Key(AppConfig.register),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          final request = RegisterRequest(
                            name: _firstNameController.text,
                            lastName: _lastNameController.text,
                            country: _selectedCountry ?? '',
                            email: _emailController.text,
                            password: _passwordController.text,
                          );
                          context.read<RegisterBloc>().add(
                            RegisterSubmitted(request),
                          );
                        }
                      },
                      child: Text(AppConfig.register),
                    );
                  }
                },
              ),
              if (_message != null)
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(_message!, style: _messageStyle),
                ),
              TextButton(
                key: Key(AppConfig.alreadyHaveAnAccount),
                onPressed: () => context.go('/login'),
                child: Text(AppConfig.alreadyHaveAnAccount),
              ),
              TextButton(
                key: Key(AppConfig.home),
                onPressed: () => context.go('/'),
                child: Text(AppConfig.home),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
