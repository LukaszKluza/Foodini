import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/config/app_config.dart';
import 'package:http/http.dart' as http;
import 'package:frontend/views/widgets/rectangular_button.dart';

class MainPageScreen extends StatefulWidget {
  final http.Client? client;

  const MainPageScreen({super.key, this.client});

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
                      AppConfig.myAccount,
                      Icons.person,
                      screenWidth,
                      screenHeight,
                      () => context.go('/account'),
                    ),
                    SizedBox(height: 16),
                    rectangularButton(
                      "Button 2",
                      Icons.do_not_disturb,
                      screenWidth,
                      screenHeight,
                      null,
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
