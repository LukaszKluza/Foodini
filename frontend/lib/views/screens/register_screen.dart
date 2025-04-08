import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/models/logged_user.dart';
import 'package:frontend/services/api_client.dart';
import 'package:frontend/services/user_provider.dart';
import 'package:frontend/utils/userValidators.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/config/app_config.dart';
import 'package:country_picker/country_picker.dart';
import 'package:provider/provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

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
    final apiClient = Provider.of<ApiClient>(context, listen: false);

    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await apiClient
          .postRequest(Uri.parse(AppConfig.registerUrl), {
            "name": _firstNameController.text,
            "last_name": _lastNameController.text,
            "age": _selectedAge,
            "country": _selectedCountry,
            "email": _emailController.text,
            "password": _passwordController.text,
          });

      setState(() {
        _isLoading = false;
      });

      if (response.statusCode == 200) {
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        final responseBody = jsonDecode(response.body);
        final loggedUser = LoggedUser.fromJson(responseBody);

        userProvider.setUser(loggedUser); 

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(AppConfig.registration, style: AppConfig.titleStyle),
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
                  validator: validateName,
                ),
                TextFormField(
                  key: Key(AppConfig.lastName),
                  controller: _lastNameController,
                  decoration: InputDecoration(labelText: AppConfig.lastName),
                  validator: validateName,
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
                  validator: (value) => validateAge(value),
                ),
                TextFormField(
                  key: Key(AppConfig.country),
                  readOnly: true,
                  decoration: InputDecoration(labelText: AppConfig.country),
                  controller: _countryController,
                  onTap: () => _pickCountry(context),
                  validator:
                      (value) => validateCountry(value, _selectedCountry),
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
                    child: Text(_errorMessage!, style: AppConfig.errorStyle),
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
