import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:frontend/blocs/user/login_bloc.dart';
import 'package:frontend/config/styles.dart';
import 'package:frontend/events/user/login_events.dart';
import 'package:frontend/listeners/user/login_listener.dart';
import 'package:frontend/models/user/login_request.dart';
import 'package:frontend/repository/user/user_repository.dart';
import 'package:frontend/services/token_storage_service.dart';
import 'package:frontend/states/login_states.dart';
import 'package:frontend/utils/query_parameters_mapper.dart';
import 'package:frontend/utils/user/user_validators.dart';

import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:frontend/l10n/app_localizations.dart';

class LoginScreen extends StatelessWidget {
  final LoginBloc? bloc;

  const LoginScreen({super.key, this.bloc});

  @override
  Widget build(BuildContext context) {
    return bloc != null
        ? BlocProvider<LoginBloc>.value(
          value: bloc!,
          child: _buildScaffold(context),
        )
        : BlocProvider<LoginBloc>(
          create:
              (_) => LoginBloc(
                Provider.of<AuthRepository>(context, listen: false),
                Provider.of<TokenStorageRepository>(context, listen: false),
              ),
          child: _buildScaffold(context),
        );
  }

  Widget _buildScaffold(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            AppLocalizations.of(context)!.login,
            style: Styles.titleStyle,
          ),
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
  TextStyle _messageStyle = Styles.errorStyle;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final pathAndQuery = Uri.base.toString().split('?');
      if (pathAndQuery.length > 1) {
        final Map<String, String> queryParameters =
            QueryParametersMapper.parseQueryParams(pathAndQuery[1]);
        if (queryParameters["status"] != null) {
          context.read<LoginBloc>().add(InitFromUrl(queryParameters["status"]));
        }
        if (queryParameters["email"] != null) {
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
                key: Key("e-mail"),
                controller: _emailController,
                decoration: InputDecoration(labelText: AppLocalizations.of(context)!.email),
                keyboardType: TextInputType.emailAddress,
                validator: (value) => validateEmail(value, context),

              ),
              TextFormField(
                key: Key("password"),
                controller: _passwordController,
                decoration: InputDecoration(labelText: AppLocalizations.of(context)!.password),
                obscureText: true,
                validator: (value) => validatePassword(value, context),
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
                  } else if (state is AccountNotVerified) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.warning, color: Colors.orange, size: 36),
                        SizedBox(height: 16),
                        Text(
                          AppLocalizations.of(context)!.accountHasNotBeenConfirmed,
                          style: Styles.warningStyle,
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 16),
                        ElevatedButton(
                          key: Key("send_verification_email_again"),
                          onPressed: () {
                            context.read<LoginBloc>().add(
                              ResendVerificationEmail(_emailController.text),
                            );
                          },
                          child: Text(AppLocalizations.of(context)!.sendVerificationEmailAgain),
                        ),
                      ],
                    );
                  } else {
                    return ElevatedButton(
                      key: Key("login"),
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
                      child: Text(AppLocalizations.of(context)!.login),
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
                key: Key("forgot_password"),
                onPressed: () => context.go('/provide_email'),
                child: Text(AppLocalizations.of(context)!.forgotPassword),
              ),
              TextButton(
                key: Key("dont_have_account"),
                onPressed: () => context.go('/register'),
                child: Text(AppLocalizations.of(context)!.dontHaveAccount),
              ),
              TextButton(
                key: Key("home"),
                onPressed: () => context.go('/'),
                child: Text(AppLocalizations.of(context)!.home),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
