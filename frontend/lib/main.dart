import 'package:flutter/material.dart';
import 'package:frontend/services/api_client.dart';
import 'package:frontend/services/user_provider.dart';
import 'package:provider/provider.dart';
import 'app_router.dart';

void main() {
  runApp(Foodini());
}

class Foodini extends StatelessWidget {
  const Foodini({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ApiClient>(create: (_) => ApiClient()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        routerConfig: router,
      ),
    );
  }
}
