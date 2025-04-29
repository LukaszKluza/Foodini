import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/blocs/register_bloc.dart';
import 'package:frontend/repository/auth_repository.dart';
import 'package:frontend/repository/token_storage_repository.dart';
import 'package:frontend/services/api_client.dart';
import 'package:mockito/annotations.dart';

@GenerateMocks([
  AuthRepository,
  RegisterBloc,
  TokenStorageRepository,
  FlutterSecureStorage,
  ApiClient,
  Dio])
void main() {}

