import 'package:frontend/repository/user/user_repository.dart';
import 'package:frontend/services/token_storage_service.dart';
import 'package:mockito/annotations.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../mocks/mocks.mocks.dart';

@GenerateMocks([UserRepository, TokenStorageRepository])
List<SingleChildWidget> getDefaultTestProviders({
  UserRepository? authRepository,
  TokenStorageRepository? tokenStorage,
}) {
  return [
    Provider<UserRepository>.value(
      value: authRepository ?? MockUserRepository(),
    ),
    Provider<TokenStorageRepository>.value(
      value: tokenStorage ?? MockTokenStorageRepository(),
    ),
  ];
}
