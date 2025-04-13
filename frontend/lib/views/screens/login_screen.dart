import 'package:flutter/material.dart';
import 'package:frontend/services/api_client.dart';
import 'package:frontend/utils/userValidators.dart';
import 'package:frontend/services/response_handler_service.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/config/app_config.dart';
import 'package:provider/provider.dart';

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
    final apiClient = Provider.of<ApiClient>(context, listen: false);

    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await apiClient.postRequest(
        Uri.parse(AppConfig.loginUrl),
        {"email": _emailController.text, "password": _passwordController.text},
      );

      ResponseHandlerService.handleAuthResponse(
        context: context,
        response: response,
        successMessage: AppConfig.successfullyLoggedIn,
        route: '/main_page',
        onError: (error) {
          setState(() {
            _errorMessage = error;
          });
        },
      );
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
          child: Text(AppConfig.login, style: AppConfig.titleStyle),
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
                      child: Text(_errorMessage!, style: AppConfig.errorStyle),
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
