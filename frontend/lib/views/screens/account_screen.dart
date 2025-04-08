import 'package:flutter/material.dart';
import 'package:frontend/services/api_client.dart';
import 'package:frontend/services/user_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/config/app_config.dart';
import 'package:frontend/views/widgets/rectangular_button.dart';
import 'package:provider/provider.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<AccountScreen> {
  Future<void> _logout(BuildContext context) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final apiClient = Provider.of<ApiClient>(context, listen: false);

    if (userProvider.user != null) {
      try {
        await apiClient.logout(userProvider.user!.id);
        userProvider.logout();
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Logout failed: $e")));
        }
      }
    }

    if (context.mounted) {
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
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
                      () => _logout(context),
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
        ],
      ),
    );
  }
}
