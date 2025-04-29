import 'package:frontend/models/user_response.dart';
import 'package:frontend/repository/user_storage.dart';
import 'package:frontend/services/api_client.dart';
import 'package:frontend/repository/token_storage_repository.dart';
import 'package:frontend/repository/auth_repository.dart';

import 'app_router.dart';
import 'models/refreshed_tokens_response.dart';

Future<void> fetchTokenTaskCallback() async {
  final TokenStorageRepository tokenStorage = TokenStorageRepository();
  final UserStorage userStorage = UserStorage();
  final String? refreshToken = await tokenStorage.getAccessToken();

  if (refreshToken != null) {
    final apiClient = ApiClient();
    final authRepository = AuthRepository(apiClient);
    RefreshedTokensResponse refreshedTokens;
    UserResponse userResponse;

    try {
      refreshedTokens = await authRepository.refreshTokens();
      await tokenStorage.saveAccessToken(refreshedTokens.accessToken);
      await tokenStorage.saveRefreshToken(refreshedTokens.refreshToken);

      userResponse = await authRepository.getUser();
      userStorage.setUser(userResponse);

      router.go('/account');
    } catch (e) {
      router.go('/');
    }
  }
}
