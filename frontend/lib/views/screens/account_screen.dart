import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/repository/auth_repository.dart';
import 'package:frontend/repository/token_storage_repository.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../blocs/account_bloc.dart';
import '../../config/app_config.dart';
import '../../events/account_events.dart';
import '../../utils/exception_converter.dart';
import '../../states/account_states.dart';
import '../widgets/rectangular_button.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (_) => AccountBloc(
            Provider.of<AuthRepository>(context, listen: false),
            Provider.of<TokenStorageRepository>(context, listen: false),
          ),
      child: Scaffold(
        appBar: AppBar(
          title: Center(
            child: Text(AppConfig.account, style: AppConfig.titleStyle),
          ),
        ),
        body: BlocListener<AccountBloc, AccountState>(
          listener: (context, state) {
            if (state is AccountLogoutSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Account loaded successfully')),
              );
            } else if (state is AccountLogoutFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    ExceptionConverter.formatErrorMessage(
                      state.error.data["detail"],
                    ),
                  ),
                ),
              );
            }
          },
          child: _AccountBody(),
        ),
      ),
    );
  }
}

class _AccountBody extends StatefulWidget {
  @override
  State<_AccountBody> createState() => _AccountScreen();
}

class _AccountScreen extends State<_AccountBody> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return BlocListener<AccountBloc, AccountState>(
      listener: (context, state) {
        if (state is AccountLogoutSuccess) {
          context.go('/');
        } else if (state is AccountLogoutFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Logout failed: ${state.error}")),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              context.go('/main_page');
            },
          ),
          title: Center(
            child: Text(AppConfig.foodini, style: AppConfig.titleStyle),
          ),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.all(35.0),
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
                        () => context.go('/change_password'),
                      ),
                      SizedBox(height: 16),
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
                      SizedBox(height: 16),
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
                  return CircularProgressIndicator();
                }
                return SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }
}
