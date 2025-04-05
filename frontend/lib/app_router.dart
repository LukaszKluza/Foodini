import 'package:frontend/views/screens/change_password_screen.dart';
import 'package:frontend/views/screens/login_screen.dart';
import 'package:go_router/go_router.dart';
import 'views/screens/home_screen.dart';
import 'views/screens/register_screen.dart';
import 'views/screens/main_page_screen.dart';
import 'views/screens/account_screen.dart';

final GoRouter router = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => HomeScreen()),
    GoRoute(path: '/register', builder: (context, state) => RegisterScreen()),
    GoRoute(path: '/login', builder: (context, state) => LoginScreen()),
    GoRoute(path: '/main_page', builder: (conext, state) => MainPageScreen()),
    GoRoute(path: '/account', builder: (conext, state) => AccountScreen()),
    GoRoute(
      path: '/change_password',
      builder: (conext, state) => ChangePasswordScreen(),
    ),
  ],
);
