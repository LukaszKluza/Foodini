import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/blocs/user/login_bloc.dart';
import 'package:frontend/config/styles.dart';
import 'package:frontend/events/user/login_events.dart';
import 'package:frontend/foodini.dart';
import 'package:frontend/l10n/app_localizations.dart';
import 'package:frontend/listeners/user/login_listener.dart';
import 'package:frontend/models/user/language.dart';
import 'package:frontend/models/user/login_request.dart';
import 'package:frontend/repository/user/user_repository.dart';
import 'package:frontend/services/token_storage_service.dart';
import 'package:frontend/states/login_states.dart';
import 'package:frontend/utils/query_parameters_mapper.dart';
import 'package:frontend/utils/user/user_validators.dart';
import 'package:frontend/views/widgets/diet_generation/action_buttons.dart';
import 'package:frontend/views/widgets/language_picker.dart';
import 'package:frontend/views/widgets/title_text.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends StatelessWidget {
  final LoginBloc? bloc;

  const LoginScreen({super.key, this.bloc});

  @override
  Widget build(BuildContext context) {
    final wrappedScaffold = Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: _buildScaffold(context),
        ),
      ),
    );

    if (bloc != null) {
      return BlocProvider<LoginBloc>.value(
        value: bloc!,
        child: wrappedScaffold,
      );
    }

    return BlocProvider<LoginBloc>(
      create: (_) => LoginBloc(
        context.read<UserRepository>(),
        context.read<TokenStorageService>(),
      ),
      child: wrappedScaffold,
    );
  }

  Widget _buildScaffold(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        title: Stack(
          alignment: Alignment.center,
          children: [
            TitleTextWidgets.scaledTitle(
              AppLocalizations.of(context)!.login,
            ),
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: Icon(Icons.translate_rounded),
                onPressed: () => LanguagePicker.show(context),
              ),
            ),
          ],
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
        if (queryParameters['status'] != null) {
          context.read<LoginBloc>().add(InitFromUrl(queryParameters['status']));
        }
        if (queryParameters['email'] != null) {
          _emailController.text = queryParameters['email']!;
        }
        if (queryParameters['language'] != null) {
          var language = Language.fromJson(queryParameters['language']!);
          context.read<LanguageCubit>().change(language);
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
        padding: const EdgeInsets.fromLTRB(35, 16, 35, 16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                key: Key('e-mail'),
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.email,
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) => validateEmail(value, context),
              ),
              TextFormField(
                key: Key('password'),
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.password,
                ),
                obscureText: true,
                validator: (value) => validatePassword(value, context),
              ),
              SizedBox(height: 20),
              BlocConsumer<LoginBloc, LoginState>(
                listener: (context, state) {
                  LoginListenerHelper.onLoginListener(
                    context: context,
                    state: state,
                    mounted: mounted,
                    setMessage: (msg) => setState(() => _message = msg),
                    setMessageStyle: (style) => setState(() => _messageStyle = style),
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
                          AppLocalizations.of(
                            context,
                          )!.accountHasNotBeenConfirmed,
                          style: Styles.warningStyle,
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 16),
                        Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 300),
                            child: SizedBox(
                              width: double.infinity,
                              child: customRetryButton(
                                Key('send_verification_email_again'),
                                () {
                                  context.read<LoginBloc>().add(
                                    ResendVerificationEmail(_emailController.text),
                                  );
                                },
                                Text(
                                  AppLocalizations.of(context)!.sendVerificationEmailAgain,
                                  style: TextStyle(
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  } else {
                    return
                      Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 220),
                          child: SizedBox(
                            width: double.infinity,
                            child: customSubmitButton(
                              Key('login'),
                              () {
                                if (_formKey.currentState!.validate()) {
                                  final request = LoginRequest(
                                    username: _emailController.text,
                                    password: _passwordController.text,
                                  );
                                  context.read<LoginBloc>().add(
                                    LoginSubmitted(request),
                                  );
                                }
                              },
                              Text(AppLocalizations.of(context)!.login),
                            ),
                          ),
                        ),
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
                key: Key('forgot_password'),
                onPressed: () => context.go('/provide-email'),
                child: Text(
                  AppLocalizations.of(context)!.forgotPassword,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.orange.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              TextButton(
                key: Key('dont_have_account'),
                onPressed: () => context.go('/register'),
                child: Text(
                  AppLocalizations.of(context)!.dontHaveAccount,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.orange.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              TextButton(
                key: Key('home'),
                onPressed: () => context.go('/'),
                child: Text(
                  AppLocalizations.of(context)!.home,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.orange.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
