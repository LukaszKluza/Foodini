import 'package:flutter/material.dart';
import 'app_router.dart';

void main() {
  runApp(Foodini());
}

class Foodini extends StatelessWidget {
  const Foodini({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: router,
    );
  }
}
