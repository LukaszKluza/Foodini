import 'package:go_router/go_router.dart';
import 'views/screens/home_screen.dart';
import 'views/screens/register_screen.dart';

final GoRouter router = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => HomeScreen()),
    GoRoute(path: "/register", builder: (context, state) => RegisterScreen()),
  ],
);
