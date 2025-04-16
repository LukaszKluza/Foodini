import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/config/app_config.dart';
import 'package:frontend/models/login_request.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../repository/auth_repository.dart';
import '../../repository/token_storage_repository.dart';
import '../../blocs/login_bloc.dart';
import '../../events/login_events.dart';
import '../../utils/exception_converter.dart';
import '../../states/login_states.dart';
import '../../utils/userValidators.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (_) => LoginBloc(
        Provider.of<AuthRepository>(context, listen: false),
        Provider.of<TokenStorageRepository>(context, listen: false),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Center(
            child: Text(AppConfig.login, style: AppConfig.titleStyle),
          ),
        ),
        body: _LoginForm(),
      ),
    );
  }
}

class _LoginForm extends StatefulWidget {
  @override
  State<_LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<_LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String? _message;
  TextStyle _messageStyle = AppConfig.errorStyle;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
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
              BlocConsumer<LoginBloc, LoginState>(
                listener: (context, state) {
                  if (state is LoginSuccess) {
                    setState(() {
                      _message = AppConfig.successfullyLoggedIn;
                      _messageStyle = AppConfig.successStyle;
                    });
                    Future.delayed(const Duration(seconds: 2), () {
                      if (mounted) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          context.go('/main_page');
                        });
                      }
                    });
                  } else if (state is LoginFailure) {
                    setState(() {
                      _message = ExceptionConverter.formatErrorMessage(
                        state.error.data["detail"],
                      );
                    });
                  }
                },
                builder: (context, state) {
                  if (state is LoginLoading) {
                    return CircularProgressIndicator();
                  } else {
                    return ElevatedButton(
                      key: Key(AppConfig.login),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          final request = LoginRequest(
                            email: _emailController.text,
                            password: _passwordController.text,
                          );
                          context.read<LoginBloc>().add(
                            LoginSubmitted(request),
                          );
                        }
                      },
                      child: Text(AppConfig.login),
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
    );
  }
}
