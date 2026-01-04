import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/blocs/user/account_bloc.dart';
import 'package:frontend/blocs/user_details/diet_form_bloc.dart';
import 'package:frontend/config/constants.dart';
import 'package:frontend/config/styles.dart';
import 'package:frontend/events/user/account_events.dart';
import 'package:frontend/events/user_details/diet_form_events.dart';
import 'package:frontend/l10n/app_localizations.dart';
import 'package:frontend/listeners/user/account_listener.dart';
import 'package:frontend/repository/user/user_repository.dart';
import 'package:frontend/services/token_storage_service.dart';
import 'package:frontend/states/account_states.dart';
import 'package:frontend/views/widgets/bottom_nav_bar.dart';
import 'package:frontend/views/widgets/language_picker.dart';
import 'package:frontend/views/widgets/menu_card.dart';
import 'package:go_router/go_router.dart';

class AccountScreen extends StatelessWidget {
  final AccountBloc? bloc;

  const AccountScreen({super.key, this.bloc});

  @override
  Widget build(BuildContext context) {
    final wrappedScaffold = Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: _AccountBody(),
        ),
      ),
    );

    if (bloc != null) {
      return BlocProvider<AccountBloc>.value(
        value: bloc!,
        child: wrappedScaffold,
      );
    }

    return BlocProvider<AccountBloc>(
      create: (_) => AccountBloc(
        context.read<UserRepository>(),
        context.read<TokenStorageService>(),
      ),
      child: wrappedScaffold,
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
    final screenWidth = min(MediaQuery.of(context).size.width, 800.0);
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Image.asset(Constants.mainFoodiniIcon, width: 124),
          ),
        ),
      ),
      body: BlocListener<AccountBloc, AccountState>(
        listener: (context, state) {
          AccountListenerHelper.accountStateListener(
            context,
            state,
            mounted: mounted,
          );
        },
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  '${AppLocalizations.of(context)!.your},',
                  style: Styles.kaushanScriptStyle(40).copyWith(
                    color: Colors.orange.shade800,
                  ),
                ),
                Text(
                  AppLocalizations.of(context)!.account,
                  style: Styles.kaushanScriptStyle(48).copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),


                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: screenWidth > 0.7 * screenHeight ? 1.8 : 1.1,
                  children: [
                    buildMenuCard(
                      context,
                      title: AppLocalizations.of(context)!.changePassword,
                      icon: Icons.settings,
                      color: Colors.orange.shade600,
                      onTap: () => context.push('/provide-email'),
                    ),
                    buildMenuCard(
                      context,
                      title: AppLocalizations.of(context)!.changeLanguage,
                      icon: Icons.translate_rounded,
                      color: Colors.orange.shade700,
                      onTap: () => LanguagePicker.show(
                        context,
                        isAccountScreen: true,
                      ),
                    ),
                    buildMenuCard(
                      context,
                      title: AppLocalizations.of(context)!.logout,
                      icon: Icons.logout,
                      color: Colors.orange.shade600,
                      onTap: () {
                        context.read<AccountBloc>().add(
                          AccountLogoutRequested(),
                        );
                        context.read<DietFormBloc>().add(
                          DietFormResetRequested(),
                        );
                      },
                    ),
                    buildMenuCard(
                      context,
                      title: AppLocalizations.of(context)!.deleteAccount,
                      icon: Icons.auto_delete,
                      color: Colors.orange.shade500,
                      onTap: () => _showDeleteAccountDialog(context),
                    ),
                  ]
                ),
                BlocBuilder<AccountBloc, AccountState>(
                  builder: (context, state) {
                    if (state is AccountActionInProgress) {
                      return const CircularProgressIndicator();
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentRoute: GoRouterState.of(context).uri.path,
      ),
    );
  }
}

void _showDeleteAccountDialog(BuildContext mainContext) {
  showDialog(
    context: mainContext,
    builder: (dialogContext) => Builder(
      builder: (innerContext) => AlertDialog(
        title: Text(
          AppLocalizations.of(mainContext)!.confirmAccountDeletion,
        ),
        content: Text(
          AppLocalizations.of(mainContext)!.accountDeletionInformation,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
            },
            child: Text(
              AppLocalizations.of(mainContext)!.cancel,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.orange,
                  fontWeight: FontWeight.w500,
                )
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              mainContext.read<AccountBloc>().add(
                AccountDeleteRequested(),
              );
              mainContext.read<DietFormBloc>().add(
                DietFormResetRequested(),
              );
            },
            child: Text(
              AppLocalizations.of(mainContext)!.delete,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.red,
                  fontWeight: FontWeight.w500,
                )
            ),
          ),
        ],
      ),
    ),
  );
}
