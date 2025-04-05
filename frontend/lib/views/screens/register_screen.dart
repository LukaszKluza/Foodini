import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/config/app_config.dart';
import 'package:http/http.dart' as http;
import 'package:country_picker/country_picker.dart';

class RegisterScreen extends StatefulWidget {
  final http.Client? client;

  const RegisterScreen({super.key, this.client});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  int? _selectedAge;
  String? _selectedCountry;

  bool _isLoading = false;
  String? _errorMessage;

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

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final client = widget.client ?? http.Client();

    try {
      final response = await client.post(
        Uri.parse(AppConfig.registerUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "name": _firstNameController.text,
          "last_name": _lastNameController.text,
          "age": _selectedAge,
          "country": _selectedCountry,
          "email": _emailController.text,
          "password": _passwordController.text,
        }),
      );

      setState(() {
        _isLoading = false;
      });

      if (response.statusCode == 200) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppConfig.succesfullyRegistered)),
        );
        context.go('/main_page');
      } else {
        final responseBody = jsonDecode(response.body);
        setState(() {
          _errorMessage = responseBody["detail"].toString();
        });
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String? _validateAge(int? value) {
    if (value == null) {
      return AppConfig.requiredAge;
    }
    return null;
  }

  String? _validateCountry(String? value) {
    if (_selectedCountry == null || _selectedCountry!.isEmpty) {
      return AppConfig.requiredCountry;
    }
    return null;
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return AppConfig.requiredName;
    }
    if (value.length < 2 ||
        value.length > 50 ||
        !RegExp(r'^[a-zA-Z]+$').hasMatch(value)) {
      return AppConfig.provideCorrectName;
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return AppConfig.requiredEmail;
    }
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
      return AppConfig.invalidEmail;
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return AppConfig.requiredPassword;
    }
    if (value.length < AppConfig.minPasswordLength) {
      return AppConfig.minimalPasswordLegth;
    }
    if (value.length > AppConfig.maxPasswordLength) {
      return AppConfig.maximalPasswordLegth;
    }
    if (!RegExp(r'^(?=.*[A-Z])(?=.*\d)').hasMatch(value)) {
      return AppConfig.passwordComplexityError;
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return AppConfig.requiredPasswordConfirmation;
    }
    if (value != _passwordController.text) {
      return AppConfig.samePasswords;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            AppConfig.registration,
            style: TextStyle(fontSize: 32, fontStyle: FontStyle.italic),
          ),
        ),
      ),
      body: SingleChildScrollView(
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
                  validator: _validateName,
                ),
                TextFormField(
                  key: Key(AppConfig.lastName),
                  controller: _lastNameController,
                  decoration: InputDecoration(labelText: AppConfig.lastName),
                  validator: _validateName,
                ),
                DropdownButtonFormField<int>(
                  key: Key(AppConfig.age),
                  value: _selectedAge,
                  decoration: InputDecoration(labelText: AppConfig.age),
                  items:
                      AppConfig.ages.map((int age) {
                        return DropdownMenuItem<int>(
                          value: age,
                          child: Text(age.toString()),
                        );
                      }).toList(),
                  onChanged: (int? newValue) {
                    setState(() {
                      _selectedAge = newValue;
                    });
                  },
                  validator: (value) => _validateAge(value),
                ),
                TextFormField(
                  key: Key(AppConfig.country),
                  readOnly: true,
                  decoration: InputDecoration(labelText: AppConfig.country),
                  controller: _countryController,
                  onTap: () => _pickCountry(context),
                  validator: _validateCountry,
                ),
                TextFormField(
                  key: Key(AppConfig.email),
                  controller: _emailController,
                  decoration: InputDecoration(labelText: AppConfig.email),
                  keyboardType: TextInputType.emailAddress,
                  validator: _validateEmail,
                ),
                TextFormField(
                  key: Key(AppConfig.password),
                  controller: _passwordController,
                  decoration: InputDecoration(labelText: AppConfig.password),
                  obscureText: true,
                  validator: _validatePassword,
                ),
                TextFormField(
                  key: Key(AppConfig.confirmPassword),
                  controller: _confirmPasswordController,
                  decoration: InputDecoration(
                    labelText: AppConfig.confirmPassword,
                  ),
                  obscureText: true,
                  validator: _validateConfirmPassword,
                ),
                SizedBox(height: 20),
                _isLoading
                    ? CircularProgressIndicator()
                    : ElevatedButton(
                      key: Key(AppConfig.register),
                      onPressed: _register,
                      child: Text(AppConfig.register),
                    ),
                if (_errorMessage != null)
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(color: Colors.red),
                    ),
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
      ),
    );
  }
}
