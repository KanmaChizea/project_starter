import 'package:project_starter/core/constants/endpoints.dart';
import 'package:project_starter/core/network/api_client.dart';
import 'package:project_starter/core/session/user.dart';
import 'package:project_starter/core/utils/app_exception.dart';
import 'package:project_starter/core/utils/result.dart';

import '../models/sign_in_result.dart';

// TODO: match your backend's auth endpoints, payloads and error statuses.
class AuthRepository {
  AuthRepository(this._api);

  final ApiClient _api;

  Future<Result<SignInResult>> signIn({
    required String email,
    required String password,
  }) async {
    final result = await _api.post<Map<String, Object?>>(
      Endpoints.login,
      data: {'email': email, 'password': password},
    );
    return switch (result) {
      Error(error: AppException(statusCode: 401)) => const Result.error(
        AppException('Invalid email or password.', statusCode: 401),
      ),
      _ => result.map(SignInResult.fromJson),
    };
  }

  Future<Result<User>> fetchCurrentUser() async {
    final result = await _api.get<Map<String, Object?>>(Endpoints.me);
    return result.map(User.fromJson);
  }

  Future<Result<void>> signOut() {
    return _api.post<void>(Endpoints.logout);
  }
}
