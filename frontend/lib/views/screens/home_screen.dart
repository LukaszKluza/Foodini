import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:frontend/config/app_config.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(AppConfig.homePage, style: AppConfig.titleStyle),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              AppConfig.welcome,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => context.go('/login'),
              child: Text(AppConfig.login),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => context.go('/register'),
              child: Text(AppConfig.register),
            ),
          ],
        ),
      ),
    );
  }
}
