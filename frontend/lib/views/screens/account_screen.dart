import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:frontend/blocs/account_bloc.dart';
import 'package:frontend/config/app_config.dart';
import 'package:frontend/events/account_events.dart';
import 'package:frontend/repository/auth_repository.dart';
import 'package:frontend/repository/token_storage_repository.dart';
import 'package:frontend/states/account_states.dart';
import 'package:frontend/utils/exception_converter.dart';
import 'package:frontend/views/widgets/rectangular_button.dart';

class AccountScreen extends StatelessWidget {
  final AccountBloc? bloc;

  const AccountScreen({super.key, this.bloc});

  @override
  Widget build(BuildContext context) {
    return bloc != null
        ? BlocProvider<AccountBloc>.value(
      value: bloc!,
      child: _AccountBody(),
    )
        : BlocProvider<AccountBloc>(
      create: (_) => AccountBloc(
        Provider.of<AuthRepository>(context, listen: false),
        Provider.of<TokenStorageRepository>(context, listen: false),
      ),
      child: _AccountBody(),
    );
  }
}

class _AccountBody extends StatefulWidget {

  @override
  State<_AccountBody> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<_AccountBody> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.go('/main_page');
          },
        ),
        title: Center(
          child: Text(AppConfig.foodini, style: AppConfig.titleStyle),
        ),
      ),
      body: BlocListener<AccountBloc, AccountState>(
        listener: (context, state) {
          if (state is AccountLogoutSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text(AppConfig.successfullyLoggedOut)),
            );
            Future.delayed(const Duration(seconds: 2), () {
              if (mounted) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  context.go('/');
                });
              }
            });
          } else if (state is AccountLogoutFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  ExceptionConverter.formatErrorMessage(
                    state.error.data,
                  ),
                ),
              ),
            );
          }
        },
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(35.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        rectangularButton(
                          AppConfig.changePassword,
                          Icons.settings,
                          screenWidth,
                          screenHeight,
                          () => context.go('/provide_email'),
                        ),
                        const SizedBox(height: 16),
                        rectangularButton(
                          AppConfig.logout,
                          Icons.logout,
                          screenWidth,
                          screenHeight,
                          () {
                            context.read<AccountBloc>().add(
                                  AccountLogoutRequested(),
                                );
                          },
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        rectangularButton(
                          "Button 3",
                          Icons.do_not_disturb,
                          screenWidth,
                          screenHeight,
                          null,
                        ),
                        const SizedBox(height: 16),
                        rectangularButton(
                          "Button 4",
                          Icons.do_not_disturb,
                          screenWidth,
                          screenHeight,
                          null,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              BlocBuilder<AccountBloc, AccountState>(
                builder: (context, state) {
                  if (state is AccountLoggingOut) {
                    return const CircularProgressIndicator();
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
