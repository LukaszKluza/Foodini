import 'package:frontend/repository/user/user_repository.dart';
import 'package:frontend/services/token_storage_service.dart';
import 'package:mockito/annotations.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../mocks/mocks.mocks.dart';

@GenerateMocks([AuthRepository, TokenStorageRepository])
List<SingleChildWidget> getDefaultTestProviders({
  AuthRepository? authRepository,
  TokenStorageRepository? tokenStorage,
}) {
  return [
    Provider<AuthRepository>.value(
      value: authRepository ?? MockAuthRepository(),
    ),
    Provider<TokenStorageRepository>.value(
      value: tokenStorage ?? MockTokenStorageRepository(),
    ),
  ];
}
