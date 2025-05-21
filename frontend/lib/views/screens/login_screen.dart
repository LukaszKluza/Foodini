import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/blocs/login_bloc.dart';
import 'package:frontend/config/app_config.dart';
import 'package:frontend/events/login_events.dart';
import 'package:frontend/listeners/login_listener.dart';
import 'package:frontend/models/login_request.dart';
import 'package:frontend/repository/auth_repository.dart';
import 'package:frontend/services/token_storage_service.dart';
import 'package:frontend/states/login_states.dart';
import 'package:frontend/utils/query_parameters_mapper.dart';
import 'package:frontend/utils/user_validators.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatelessWidget {
  final LoginBloc? bloc;

  const LoginScreen({super.key, this.bloc});

  @override
  Widget build(BuildContext context) {
    return bloc != null
        ? BlocProvider<LoginBloc>.value(
      value: bloc!,
      child: _buildScaffold(),
    )
        : BlocProvider<LoginBloc>(
      create: (_) => LoginBloc(
        Provider.of<AuthRepository>(context, listen: false),
        Provider.of<TokenStorageRepository>(context, listen: false),
      ),
      child: _buildScaffold(),
    );
  }

  Widget _buildScaffold() {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(AppConfig.login, style: AppConfig.titleStyle),
        ),
      ),
      body: _LoginForm(),
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
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final pathAndQuery = Uri.base.toString().split('?');
      if (pathAndQuery.length > 1) {
        final Map<String, String> queryParameters = QueryParametersMapper
            .parseQueryParams(pathAndQuery[1]);
        if (queryParameters["status"] != null) {
          context.read<LoginBloc>().add(InitFromUrl(queryParameters["status"]));
        }
        if (queryParameters["email"] != null){
          _emailController.text = queryParameters["email"]!;
        }
      }
    });
  }

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
                  LoginListenerHelper.onLoginListener(
                    context: context,
                    state: state,
                    setState: setState,
                    mounted: mounted,
                    setMessage: (msg) => _message = msg,
                    setMessageStyle: (style) => _messageStyle = style,
                  );
                },
                builder: (context, state) {
                  if (state is ActionInProgress) {
                    return CircularProgressIndicator();
                  } else if (state is AccountNotVerified){
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.warning, color: Colors.orange, size: 36),
                        SizedBox(height: 16),
                        Text(
                        AppConfig.accountHasNotBeenConfirmed,
                          style: AppConfig.warningStyle,
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 16),
                        ElevatedButton(
                          key: Key(AppConfig.sendVerificationEmailAgain),
                          onPressed: () {
                            context.read<LoginBloc>().add(ResendVerificationEmail(_emailController.text));
                          },
                          child: Text(AppConfig.sendVerificationEmailAgain),
                        ),
                      ],
                    );
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
                key: Key(AppConfig.forgotPassword),
                onPressed: () => context.go('/provide_email'),
                child: Text(AppConfig.forgotPassword),
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
