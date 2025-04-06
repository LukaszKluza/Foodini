import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/config/app_config.dart';
import 'package:http/http.dart' as http;

class ChangePasswordScreen extends StatefulWidget {
  final http.Client? client;

  const ChangePasswordScreen({super.key, this.client});

  @override
  State<ChangePasswordScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmNewPasswordController =
      TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final client = widget.client ?? http.Client();

    try {
      final response = await client.post(
        Uri.parse(AppConfig.changePasswordUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": _emailController.text,
          "password": _newPasswordController.text,
        }),
      );

      if (response.statusCode == 200) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            key: Key(AppConfig.successfullyLoggedIn),
            content: Text(AppConfig.successfullyLoggedIn),
          ),
        );
        context.go('/account');
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

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return AppConfig.requiredEmail;
    }
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
      return AppConfig.invalidEmail;
    }
    return null;
  }

  String? _validateNewPassword(String? value) {
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

  String? _validateConfirmNewPassword(String? value) {
    if (value == null || value.isEmpty) {
      return AppConfig.requiredPasswordConfirmation;
    }
    if (value != _newPasswordController.text) {
      return AppConfig.samePasswords;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            context.go('/account');
          },
        ),
        title: Center(
          child: Text(
            AppConfig.changePassword,
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
                    key: Key(AppConfig.email),
                    controller: _emailController,
                    decoration: InputDecoration(labelText: AppConfig.email),
                    keyboardType: TextInputType.emailAddress,
                    validator: _validateEmail,
                  ),
                  TextFormField(
                    key: Key(AppConfig.newPassword),
                    controller: _newPasswordController,
                    decoration: InputDecoration(
                      labelText: AppConfig.newPassword,
                    ),
                    obscureText: true,
                    validator: _validateNewPassword,
                  ),
                  TextFormField(
                    key: Key(AppConfig.confirmPassword),
                    controller: _confirmNewPasswordController,
                    decoration: InputDecoration(
                      labelText: AppConfig.confirmPassword,
                    ),
                    obscureText: true,
                    validator: _validateConfirmNewPassword,
                  ),
                  SizedBox(height: 20),
                  _isLoading
                      ? CircularProgressIndicator()
                      : ElevatedButton(
                        key: Key(AppConfig.changePassword),
                        onPressed: _changePassword,
                        child: Text(AppConfig.changePassword),
                      ),
                  if (_errorMessage != null)
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(color: Colors.red),
                      ),
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
