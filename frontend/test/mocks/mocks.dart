import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/blocs/user/register_bloc.dart';
import 'package:frontend/foodini.dart';
import 'package:frontend/repository/user/user_repository.dart';
import 'package:frontend/repository/user_details/user_details_repository.dart';
import 'package:frontend/services/token_storage_service.dart';
import 'package:frontend/services/api_client.dart';
import 'package:mockito/annotations.dart';

@GenerateMocks([
  UserRepository,
  RegisterBloc,
  TokenStorageRepository,
  UserDetailsRepository,
  FlutterSecureStorage,
  ApiClient,
  ErrorInterceptorHandler,
  LanguageCubit,
  Dio])
void main() {}
