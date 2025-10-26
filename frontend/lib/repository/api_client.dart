import 'package:dio/dio.dart';
import 'package:frontend/config/endpoints.dart';
import 'package:frontend/models/diet_generation/daily_meals_create.dart';
import 'package:frontend/models/diet_generation/meal_info_update_request.dart';
import 'package:frontend/models/diet_generation/meal_type.dart';
import 'package:frontend/models/user/change_language_request.dart';
import 'package:frontend/models/user/change_password_request.dart';
import 'package:frontend/models/user/language.dart';
import 'package:frontend/models/user/login_request.dart';
import 'package:frontend/models/user/provide_email_request.dart';
import 'package:frontend/models/user/register_request.dart';
import 'package:frontend/models/user_details/diet_form.dart';
import 'package:frontend/models/user_details/macros.dart';
import 'package:frontend/services/token_storage_service.dart';
import 'package:frontend/utils/global_error_interceptor.dart';

class ApiClient {
  final Dio _client;
  final TokenStorageService _tokenStorage;

  ApiClient([Dio? client, TokenStorageService? tokenStorage])
    : _client =
          client ??
          Dio(BaseOptions(headers: {'Content-Type': 'application/json'})),
      _tokenStorage = tokenStorage ?? TokenStorageService() {
    _client.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final requiresAuth = options.extra['requiresAuth'] == true;

          if (requiresAuth) {
            final accessToken = await _tokenStorage.getAccessToken();
            options.headers['Authorization'] = 'Bearer $accessToken';
          }
          return handler.next(options);
        },
      ),
    );
    _client.interceptors.add(GlobalErrorInterceptor(this, _tokenStorage));
  }

  get dio => _client;

  Future<Response> getUser(int userId) {
    return _client.get(
      Endpoints.users,
      queryParameters: {'user_id': userId},
      options: Options(extra: {'requiresAuth': true}),
    );
  }

  Future<Response> register(RegisterRequest request) {
    return _client.post(
      Endpoints.users,
      data: request.toJson(),
      options: Options(extra: {'requiresAuth': false}),
    );
  }

  Future<Response> login(LoginRequest request) {
    return _client.post(
      Endpoints.login,
      data: request.toJson(),
      options: Options(extra: {'requiresAuth': false}),
    );
  }

  Future<Response> provideEmail(ProvideEmailRequest request) {
    return _client.post(
      Endpoints.changePassword,
      data: request.toJson(),
      options: Options(extra: {'requiresAuth': false}),
    );
  }

  Future<Response> changePassword(ChangePasswordRequest request) {
    return _client.post(
      Endpoints.confirmNewPassword,
      data: request.toJson(),
      options: Options(extra: {'requiresAuth': false}),
    );
  }

  Future<Response> changeLanguage(ChangeLanguageRequest request, int userId) {
    return _client.patch(
      Endpoints.changeLanguage,
      data: request.toJson(),
      queryParameters: {'user_id': userId},
      options: Options(extra: {'requiresAuth': true}),
    );
  }

  Future<Response> refreshTokens(int userId) async {
    final refreshToken = await _tokenStorage.getRefreshToken();
    return _client.post(
      Endpoints.refreshTokens,
      queryParameters: {'user_id': userId},
      options: Options(headers: {'Authorization': 'Bearer $refreshToken'}),
    );
  }

  Future<Response> logout(int userId) {
    return _client.get(
      Endpoints.logout,
      queryParameters: {'user_id': userId},
      options: Options(extra: {'requiresAuth': true}),
    );
  }

  Future<Response> resendVerificationMail(String email) {
    return _client.get(
      Endpoints.resendVerificationEmail,
      queryParameters: {'email': email},
      options: Options(extra: {'requiresAuth': false}),
    );
  }

  Future<Response> delete(int userId) {
    return _client.delete(
      Endpoints.users,
      queryParameters: {'user_id': userId},
      options: Options(extra: {'requiresAuth': true}),
    );
  }

  Future<Response> refreshRequest(RequestOptions requestOptions) async {
    return _client.request(
      requestOptions.path,
      queryParameters: requestOptions.queryParameters,
      data: requestOptions.data,
      options: Options(
        method: requestOptions.method,
        headers: requestOptions.headers,
        extra: {'requiresAuth': true},
      ),
    );
  }

  // user details
  Future<Response> getDietPreferences(int userId) {
    return _client.get(
      Endpoints.dietPreferences,
      queryParameters: {'user_id': userId},
      options: Options(extra: {'requiresAuth': true}),
    );
  }

  Future<Response> submitDietForm(DietForm request, int userId) {
    return _client.post(
      Endpoints.dietPreferences,
      data: request.toJson(),
      queryParameters: {'user_id': userId},
      options: Options(extra: {'requiresAuth': true}),
    );
  }

  Future<Response> submitMacrosChange(Macros request, int userId) {
    return _client.patch(
      Endpoints.userCaloriesPrediction,
      data: request.toJson(),
      queryParameters: {'user_id': userId},
      options: Options(extra: {'requiresAuth': true}),
    );
  }

  Future<Response> addCaloriesPrediction(int userId) {
    return _client.post(
      Endpoints.userCaloriesPrediction,
      queryParameters: {'user_id': userId},
      options: Options(extra: {'requiresAuth': true}),
    );
  }

  Future<Response> getCaloriesPrediction(int userId) {
    return _client.get(
      Endpoints.userCaloriesPrediction,
      queryParameters: {'user_id': userId},
      options: Options(extra: {'requiresAuth': true}),
    );
  }

  // diet prediction
  Future<Response> getMealRecipe(int recipeId, Language language, int userId) {
    return _client.get(
      '${Endpoints.mealRecipe}/$recipeId',
      queryParameters: {'user_id': userId, 'language': language.toJson()},
      options: Options(extra: {'requiresAuth': true}),
    );
  }

  Future<Response> generateMealPlan(int userId) {
    return _client.post(
      Endpoints.generateMealPlan,
      queryParameters: {'user_id': userId},
      options: Options(extra: {'requiresAuth': true}),
    );
  }

  // diet-generation
  Future<Response> getDailySummaryMeals(DateTime day, int userId) {
    return _client.get(
      '${Endpoints.dailySummaryMeals}/$day',
      queryParameters: {'user_id': userId},
      options: Options(extra: {'requiresAuth': true}),
    );
  }

  Future<Response> addDailySummaryMeals(DailyMealsCreate dailyMealsCreate, int userId) {
    return _client.post(
      Endpoints.dailySummaryMeals,
      data: dailyMealsCreate.toJson,
      queryParameters: {'user_id': userId},
      options: Options(extra: {'requiresAuth': true}),
    );
  }

  Future<Response> updateDailySummaryMeals(MealInfoUpdateRequest mealInfoUpdateRequest, int userId) {
    return _client.patch(
      Endpoints.dailySummaryMeals,
      data: mealInfoUpdateRequest.toJson,
      queryParameters: {'user_id': userId},
      options: Options(extra: {'requiresAuth': true}),
    );
  }

  Future<Response> addCustomMeal(DailyMealsCreate dailyMealsCreate, int userId) {
    return _client.patch(
      Endpoints.dailySummaryCustomMeal,
      data: dailyMealsCreate.toJson,
      queryParameters: {'user_id': userId},
      options: Options(extra: {'requiresAuth': true}),
    );
  }

  Future<Response> getDailySummaryMacros(DateTime day, int userId) {
    return _client.get(
      '${Endpoints.dailySummaryMacros}/$day',
      queryParameters: {'user_id': userId},
      options: Options(extra: {'requiresAuth': true}),
    );
  }

  Future<Response> addDailySummaryMacros(DailyMealsCreate dailyMealsCreate, int userId) {
    return _client.post(
      Endpoints.dailySummaryMacros,
      data: dailyMealsCreate.toJson,
      queryParameters: {'user_id': userId},
      options: Options(extra: {'requiresAuth': true}),
    );
  }

  // meals
  Future<Response> getMealIconInfo(MealType mealType, int userId) {
    return _client.get(
      Endpoints.mealIconInfo,
      queryParameters: {'user_id': userId, 'meal_type': mealType.toJson()},
      options: Options(extra: {'requiresAuth': true}),
    );
  }

  Future<Response> getMealDetails(int mealId, int userId) {
    return _client.get(
      '${Endpoints.meal}/$mealId',
      queryParameters: {'user_id': userId},
      options: Options(extra: {'requiresAuth': true}),
    );
  }
}
