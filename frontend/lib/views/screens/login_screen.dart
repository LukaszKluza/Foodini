import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/utils/userValidators.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/config/app_config.dart';
import 'package:http/http.dart' as http;

class LoginScreen extends StatefulWidget {
  final http.Client? client;

  const LoginScreen({super.key, this.client});

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

    final client = widget.client ?? http.Client();

    try {
      final response = await client.post(
        Uri.parse(AppConfig.loginUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": _emailController.text,
          "password": _passwordController.text,
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
          child: Text(
            AppConfig.login,
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
                    key: Key(AppConfig.password),
                    controller: _passwordController,
                    decoration: InputDecoration(labelText: AppConfig.password),
                    obscureText: true,
                    validator: validatePassword,
                  ),
                  SizedBox(height: 20),
                  _isLoading
                      ? CircularProgressIndicator()
                      : ElevatedButton(
                        key: Key(AppConfig.login),
                        onPressed: _login,
                        child: Text(AppConfig.login),
                      ),
                  if (_errorMessage != null)
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        _errorMessage!,
                        style: AppConfig.errorStyle,
                      ),
                    ),
                  TextButton(
                    key: Key(AppConfig.dontHaveAccount),
                    onPressed: () => context.go('/register'),
                    child: Text(AppConfig.dontHaveAccount),
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
        ],
      ),
    );
  }
}
