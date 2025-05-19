import 'package:flutter/cupertino.dart';
import 'package:frontend/services/token_storage_service.dart';
import 'package:frontend/views/screens/account_screen.dart';
import 'package:frontend/views/screens/change_password_screen.dart';
import 'package:frontend/views/screens/login_screen.dart';
import 'package:frontend/views/screens/main_page_screen.dart';
import 'package:frontend/views/screens/provide_email_screen.dart';
import 'package:frontend/views/screens/register_screen.dart';
import 'package:frontend/views/screens/home_screen.dart';
import 'package:go_router/go_router.dart';

final TokenStorageRepository _storage = TokenStorageRepository();

final GoRouter router = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => HomeScreen()),
    GoRoute(path: '/register', builder: (context, state) => RegisterScreen()),
    GoRoute(path: '/login', builder: (context, state) => LoginScreen()),
    GoRoute(
      path: '/main_page',
      builder: (context, state) => MainPageScreen(),
      redirect: (context, state) => _redirectIfUnauthenticated(context),
    ),
    GoRoute(
      path: '/account',
      builder: (context, state) => AccountScreen(),
      redirect: (context, state) => _redirectIfUnauthenticated(context),
    ),
    GoRoute(
      path: '/change_password',
      builder: (context, state) => ChangePasswordScreen(),
    ),
    GoRoute(
      path: '/provide_email',
      builder: (context, state) => ProvideEmailScreen(),
    ),
  ],
);

Future<String?> _redirectIfUnauthenticated(BuildContext context) async {
  final token = await _storage.getAccessToken();
  return token == null ? '/login' : null;
}