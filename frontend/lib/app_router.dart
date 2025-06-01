import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/blocs/user_details/diet_form_bloc.dart';
import 'package:frontend/repository/user_details/user_details_repository.dart';
import 'package:frontend/services/token_storage_service.dart';
import 'package:frontend/views/screens/user/account_screen.dart';
import 'package:frontend/views/screens/user_details/calories_prediction_screen.dart';
import 'package:frontend/views/screens/user/change_password_screen.dart';
import 'package:frontend/views/screens/user_details/diet_preferences_screen.dart';
import 'package:frontend/views/screens/user/login_screen.dart';
import 'package:frontend/views/screens/main_page_screen.dart';
import 'package:frontend/views/screens/user_details/profile_details_screen.dart';
import 'package:frontend/views/screens/user/provide_email_screen.dart';
import 'package:frontend/views/screens/user/register_screen.dart';
import 'package:frontend/views/screens/user/home_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

final TokenStorageRepository _storage = TokenStorageRepository();

final GoRouter router = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => HomeScreen()),
    GoRoute(path: '/register', builder: (context, state) => RegisterScreen()),
    GoRoute(
      path: '/login',
      pageBuilder:
          (context, state) => MaterialPage(
            key: ValueKey(state.uri.toString()),
            child: LoginScreen(),
          ),
    ),
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
      path: '/profile_details',
      builder: (context, state) => ProfileDetailsScreen(),
    ),
    GoRoute(
      path: '/diet_preferences',
      builder: (context, state) => DietPreferencesScreen(),
      //TODO Fix if after adding navbar and first screen
      // redirect: (context, state) => _redirectIfUnauthenticated(context),
    ),
    GoRoute(
      path: '/calories_prediction',
      builder: (context, state) => CaloriesPredictionScreen(),
      //TODO Fix if after adding navbar and first screen
      // redirect: (context, state) => _redirectIfUnauthenticated(context),
    ),
    GoRoute(
      path: '/change_password',
      pageBuilder:
          (context, state) => MaterialPage(
            key: ValueKey(state.uri.toString()),
            child: ChangePasswordScreen(),
          ),
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
