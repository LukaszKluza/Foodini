import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/utils/userValidators.dart';
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
            style: AppConfig.titleStyle,
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
                    validator: validateEmail,
                  ),
                  TextFormField(
                    key: Key(AppConfig.newPassword),
                    controller: _newPasswordController,
                    decoration: InputDecoration(
                      labelText: AppConfig.newPassword,
                    ),
                    obscureText: true,
                    validator: validatePassword,
                  ),
                  TextFormField(
                    key: Key(AppConfig.confirmPassword),
                    controller: _confirmNewPasswordController,
                    decoration: InputDecoration(
                      labelText: AppConfig.confirmPassword,
                    ),
                    obscureText: true,
                    validator: (value) => validateConfirmPassword(value, _newPasswordController.text),
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
                        style: AppConfig.errorStyle,
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
