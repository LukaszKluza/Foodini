import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/blocs/user/register_bloc.dart';
import 'package:frontend/foodini.dart';
import 'package:frontend/repository/api_client.dart';
import 'package:frontend/repository/diet_prediction/meal_recipe_repository.dart';
import 'package:frontend/repository/user/user_repository.dart';
import 'package:frontend/repository/user_details/user_details_repository.dart';
import 'package:frontend/services/token_storage_service.dart';
import 'package:mockito/annotations.dart';

@GenerateMocks([
  UserRepository,
  RegisterBloc,
  TokenStorageService,
  UserDetailsRepository,
  MealRecipeRepository,
  FlutterSecureStorage,
  ApiClient,
  ErrorInterceptorHandler,
  LanguageCubit,
  Dio,
])
void main() {}
