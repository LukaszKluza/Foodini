import 'package:frontend/models/user/user_response.dart';
import 'package:frontend/repository/user/user_storage.dart';
import 'package:frontend/services/api_client.dart';
import 'package:frontend/repository/user/user_repository.dart';
import 'package:frontend/services/token_storage_service.dart';

import 'app_router.dart';
import 'models/user/refreshed_tokens_response.dart';

Future<void> fetchTokenTaskCallback([
  TokenStorageRepository? tokenStorage,
]) async {
  final UserStorage userStorage = UserStorage();
  final String? refreshToken =
      await (tokenStorage ?? TokenStorageRepository()).getAccessToken();

  if (refreshToken != null) {
    final apiClient = ApiClient();
    final authRepository = UserRepository(apiClient);
    RefreshedTokensResponse refreshedTokens;
    UserResponse userResponse;

    try {
      final userId = UserStorage().getUserId;

      if (userId != null) {
        refreshedTokens = await authRepository.refreshTokens(userId);
        await TokenStorageRepository().saveAccessToken(
          refreshedTokens.accessToken,
        );
        await TokenStorageRepository().saveRefreshToken(
          refreshedTokens.refreshToken,
        );

        userResponse = await authRepository.getUser(userId);
        userStorage.setUser(userResponse);

        router.go('/account');
      }
    } catch (e) {
      userStorage.removeUser();
      await TokenStorageRepository().deleteAccessToken();
      await TokenStorageRepository().deleteRefreshToken();

      router.go('/');
    }
  }
}
