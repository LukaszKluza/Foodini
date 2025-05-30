import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/blocs/register_bloc.dart';
import 'package:frontend/repository/user_repository.dart';
import 'package:frontend/services/token_storage_service.dart';
import 'package:frontend/services/api_client.dart';
import 'package:mockito/annotations.dart';

@GenerateMocks([
  AuthRepository,
  RegisterBloc,
  TokenStorageRepository,
  FlutterSecureStorage,
  ApiClient,
  ErrorInterceptorHandler,
  Dio])
void main() {}

