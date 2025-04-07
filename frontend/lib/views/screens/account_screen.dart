import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/config/app_config.dart';
import 'package:frontend/views/widgets/rectangular_button.dart';

class AccountScreen extends StatefulWidget {

  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<AccountScreen> {
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
          child: Text(
            AppConfig.foodini,
            style: AppConfig.titleStyle,
          ),
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
                      () => context.go('/'),
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
