import 'package:frontend/services/api_client.dart';
import 'package:frontend/repository/token_storage_repository.dart';
import 'package:frontend/repository/auth_repository.dart';

const fetchTokenTask = 'fetchTokenTask';

Future<void> fetchTokenTaskCallback() async {
  final TokenStorageRepository tokenStorage = TokenStorageRepository();
  final String? refreshToken = await tokenStorage.getAccessToken();

  if (refreshToken != null) {
    final apiClient = ApiClient();
    final authRepository = AuthRepository(apiClient);

    final newAccessToken = await authRepository.refreshAccessToken();
    await tokenStorage.saveAccessToken(newAccessToken);
  }
}
