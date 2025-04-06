import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/config/app_config.dart';
import 'package:http/http.dart' as http;
import 'package:frontend/views/widgets/rectangular_button.dart';

class AccountScreen extends StatefulWidget {
  final http.Client? client;

  const AccountScreen({super.key, this.client});

  @override
  State<AccountScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<AccountScreen> {
  @override
  Widget build(BuildContext context) {
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
            style: TextStyle(fontSize: 32, fontStyle: FontStyle.italic),
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
                      () => context.go('/change_password'),
                    ),
                    SizedBox(height: 16),
                    rectangularButton("Button 2", Icons.do_not_disturb, null),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    rectangularButton("Button 3", Icons.do_not_disturb, null),
                    SizedBox(height: 16),
                    rectangularButton("Button 4", Icons.do_not_disturb, null),
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
