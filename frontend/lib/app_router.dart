import 'package:flutter/material.dart';
import 'package:frontend/models/diet_generation/meal_type.dart';
import 'package:frontend/services/token_storage_service.dart';
import 'package:frontend/views/screens/diet_generation/daily_meals_screen.dart';
import 'package:frontend/views/screens/diet_generation/meal_details_screen.dart';
import 'package:frontend/views/screens/diet_generation/meal_recipe_screen.dart';
import 'package:frontend/views/screens/main_page_screen.dart';
import 'package:frontend/views/screens/user/account_screen.dart';
import 'package:frontend/views/screens/user/change_password_screen.dart';
import 'package:frontend/views/screens/user/home_screen.dart';
import 'package:frontend/views/screens/user/login_screen.dart';
import 'package:frontend/views/screens/user/provide_email_screen.dart';
import 'package:frontend/views/screens/user/register_screen.dart';
import 'package:frontend/views/screens/user_details/calories_prediction_screen.dart';
import 'package:frontend/views/screens/user_details/diet_preferences_screen.dart';
import 'package:frontend/views/screens/user_details/prediction_results_screen.dart';
import 'package:frontend/views/screens/user_details/profile_details_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid_value.dart';

final TokenStorageService _storage = TokenStorageService();

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
      path: '/main-page',
      builder: (context, state) => MainPageScreen(),
      redirect: (context, state) => _redirectIfUnauthenticated(context),
    ),
    GoRoute(
      path: '/account',
      builder: (context, state) => AccountScreen(),
      redirect: (context, state) => _redirectIfUnauthenticated(context),
    ),
    GoRoute(
      path: '/profile-details',
      builder: (context, state) => ProfileDetailsScreen(),
      redirect: (context, state) => _redirectIfUnauthenticated(context),
    ),
    GoRoute(
      path: '/diet-preferences',
      builder: (context, state) => DietPreferencesScreen(),
      redirect: (context, state) => _redirectIfUnauthenticated(context),
    ),
    GoRoute(
      path: '/calories-prediction',
      builder: (context, state) => CaloriesPredictionScreen(),
      redirect: (context, state) => _redirectIfUnauthenticated(context),
    ),
    GoRoute(
      path: '/meal-recipe/:id',
      builder: (context, state) {
        final id = UuidValue.fromString(state.pathParameters['id']!);
        return MealRecipeScreen(mealId: id);
      },
      redirect: (context, state) {
        try {
          UuidValue.fromString(state.pathParameters['id']!);
          return _redirectIfUnauthenticated(context);
        } catch (_) {
          return '/.../meal-recipe/${state.pathParameters['id']}';
        }
      },
    ),
    GoRoute(
      path: '/daily-meals/:date',
      builder: (context, state) {
        final date = DateTime.tryParse(state.pathParameters['date']!)!;
        return DailyMealsScreen(
          selectedDate: DateTime(date.year, date.month, date.day),
        );
      },
      redirect: (context, state) {
        try {
          DateTime.tryParse(state.pathParameters['date']!)!;
          return _redirectIfUnauthenticated(context);
        } catch (_) {
          return '/.../daily-meals/${state.pathParameters['date']}';
        }
      },
    ),
    GoRoute(
      path: '/change-password',
      pageBuilder:
          (context, state) => MaterialPage(
            key: ValueKey(state.uri.toString()),
            child: ChangePasswordScreen(),
          ),
    ),
    GoRoute(
      path: '/provide-email',
      builder: (context, state) => ProvideEmailScreen(),
    ),
    GoRoute(
      path: '/calories-result',
      builder: (context, state) => PredictionResultsScreen(),
      redirect: (context, state) => _redirectIfUnauthenticated(context),
    ),
    GoRoute(
      path: '/meal-details/:mealType/:date',
      builder: (context, state) {
        final mealType = MealType.fromJson(state.pathParameters['mealType']!);
        final date = DateTime.tryParse(state.pathParameters['date']!)!;
        return MealDetailsScreen(mealType: mealType, day: date);
      },
      redirect: (context, state) {
        try {
          MealType.fromJson(state.pathParameters['mealType']!);
          DateTime.tryParse(state.pathParameters['date']!)!;
          return _redirectIfUnauthenticated(context);
        } catch (_) {
          return '/.../meal-details/${state.pathParameters['mealType']}';
        }
      },
    ),
  ],
);

Future<String?> _redirectIfUnauthenticated(BuildContext context) async {
  final token = await _storage.getAccessToken();
  return token == null ? '/login' : null;
}
