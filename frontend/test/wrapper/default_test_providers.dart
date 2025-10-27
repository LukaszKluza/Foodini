import 'package:frontend/repository/user/user_repository.dart';
import 'package:frontend/services/token_storage_service.dart';
import 'package:mockito/annotations.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../mocks/mocks.mocks.dart';

@GenerateMocks([UserRepository, TokenStorageService])
List<SingleChildWidget> getDefaultTestProviders({
  UserRepository? authRepository,
  TokenStorageService? tokenStorage,
}) {
  return [
    Provider<UserRepository>.value(
      value: authRepository ?? MockUserRepository(),
    ),
    Provider<TokenStorageService>.value(
      value: tokenStorage ?? MockTokenStorageService(),
    ),
  ];
}
