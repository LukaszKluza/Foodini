import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:frontend/config/app_config.dart';
import 'package:frontend/config/styles.dart';
import 'package:frontend/views/widgets/rectangular_button.dart';

class MainPageScreen extends StatefulWidget {
  const MainPageScreen({super.key});

  @override
  State<MainPageScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<MainPageScreen> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(AppConfig.foodini, style: Styles.titleStyle),
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
                      AppConfig.myAccount,
                      Icons.person,
                      screenWidth,
                      screenHeight,
                      () => context.go('/account'),
                    ),
                    SizedBox(height: 16),
                    rectangularButton(
                      AppConfig.dietPreferences,
                      Icons.food_bank_rounded,
                      screenWidth,
                      screenHeight,
                      () => context.go('/profile_details'),
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
