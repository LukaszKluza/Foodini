import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/config/app_config.dart';
import 'package:http/http.dart' as http;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final response = await http.post(
      Uri.parse(AppConfig.loginUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": _emailController.text,
        "password": _passwordController.text,
      }),
    );

    setState(() {
      _isLoading = false;
    });

    if (response.statusCode == 200) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(AppConfig.successfullyLoggedIn)));
      context.go('/home'); // TODO
    } else {
      final responseBody = jsonDecode(response.body);
      setState(() {
        _errorMessage = responseBody["detail"] ?? AppConfig.loginFailed;
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

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return AppConfig.requiredPassword;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            AppConfig.login,
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
                    controller: _emailController,
                    decoration: InputDecoration(labelText: AppConfig.email),
                    keyboardType: TextInputType.emailAddress,
                    validator: _validateEmail,
                  ),
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(labelText: AppConfig.password),
                    obscureText: true,
                    validator: _validatePassword,
                  ),
                  SizedBox(height: 20),
                  _isLoading
                      ? CircularProgressIndicator()
                      : ElevatedButton(
                        onPressed: _login,
                        child: Text(AppConfig.login),
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
                    onPressed: () => context.go('/register'),
                    child: Text(AppConfig.dontHaveAccount),
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
