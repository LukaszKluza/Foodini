import 'package:frontend/repository/token_storage_repository.dart';
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
    GoRoute(path: '/main_page', builder: (context, state) => MainPageScreen()),
    GoRoute(
      path: '/account',
      builder: (context, state) => AccountScreen(),
      redirect: (context, state) async {
        final token = await _storage.getAccessToken();
        if (token == null) {
          return '/login';
        }
        return null;
      },
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
