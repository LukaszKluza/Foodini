import 'package:dio/dio.dart';
import 'package:frontend/blocs/register_bloc.dart';
import 'package:frontend/repository/auth_repository.dart';
import 'package:frontend/repository/token_storage_repository.dart';
import 'package:frontend/services/api_client.dart';
import 'package:mockito/annotations.dart';

@GenerateMocks([AuthRepository, RegisterBloc, TokenStorageRepository, ApiClient, Dio])
void main() {}

