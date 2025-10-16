import 'package:frontend/app_router.dart';
import 'package:frontend/models/user/refreshed_tokens_response.dart';
import 'package:frontend/models/user/user_response.dart';
import 'package:frontend/repository/api_client.dart';
import 'package:frontend/repository/user/user_repository.dart';
import 'package:frontend/repository/user/user_storage.dart';
import 'package:frontend/services/token_storage_service.dart';

Future<void> fetchTokenTaskCallback([
  TokenStorageService? tokenStorage,
]) async {
  final UserStorage userStorage = UserStorage();
  final String? refreshToken =
      await (tokenStorage ?? TokenStorageService()).getAccessToken();

  if (refreshToken != null) {
    final apiClient = ApiClient();
    final authRepository = UserRepository(apiClient);
    RefreshedTokensResponse refreshedTokens;
    UserResponse userResponse;

    try {
      final userId = UserStorage().getUserId;

      if (userId != null) {
        refreshedTokens = await authRepository.refreshTokens(userId);
        await TokenStorageService().saveAccessToken(
          refreshedTokens.accessToken,
        );
        await TokenStorageService().saveRefreshToken(
          refreshedTokens.refreshToken,
        );

        userResponse = await authRepository.getUser(userId);
        userStorage.setUser(userResponse);

        router.go('/account');
      }
    } catch (e) {
      userStorage.removeUser();
      await TokenStorageService().deleteAccessToken();
      await TokenStorageService().deleteRefreshToken();

      router.go('/');
    }
  }
}
