import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/config/app_config.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordController = TextEditingController();

  void _register() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(AppConfig.succesfullyRegistered)));
    }
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return AppConfig.requiredName;
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
            AppConfig.register,
            style: TextStyle(fontSize: 32, fontStyle: FontStyle.italic),
          ),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.all(35.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    decoration: InputDecoration(labelText: 'First name'),
                    validator: _validateName,
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Last name'),
                    validator: _validateName,
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'E-mail'),
                    keyboardType: TextInputType.emailAddress,
                    validator: _validateEmail,
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Password'),
                    obscureText: true,
                    controller: _passwordController,
                    validator: _validatePassword,
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Confirm password'),
                    obscureText: true,
                    validator: _validateConfirmPassword,
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _register,
                    child: Text(AppConfig.register),
                  ),
                  TextButton(
                    onPressed: () => context.go('/login'),
                    child: Text(AppConfig.alreadyHaveAnAccount),
                  ),
                  TextButton(
                    onPressed: () => context.go('/'),
                    child: Text(AppConfig.home),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
