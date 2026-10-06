import 'package:project_starter/core/network/network_exception.dart';
import 'package:project_starter/core/session/session_cubit.dart';
import 'package:project_starter/core/session/user.dart';
import 'package:project_starter/core/utils/app_logger.dart';
import 'package:project_starter/core/utils/result.dart';

import '../repositories/auth_repository.dart';

class AuthService {
  AuthService(this._repository, this._session);

  final AuthRepository _repository;
  final SessionCubit _session;

  Future<void> restoreSession() async {
    if (_session.isResolved) return;

    try {
      final accessToken = await _session.readAccessToken();

      if (accessToken == null) {
        await _session.clear();
        return;
      }

      final result = await _repository.fetchCurrentUser();

      switch (result) {
        case Ok(:final value):
          await _session.start(value);

        case Error(error: UnauthorizedException()):
          await _session.clear();

        case Error():
          final cachedUser = await _session.readCachedUser();

          if (cachedUser != null) {
            await _session.start(cachedUser);
          } else {
            await _session.clear(forgetToken: false);
          }
      }
    } catch (error, stackTrace) {
      AppLogger.log('restoreSession failed: $error\n$stackTrace');
    } finally {
      if (!_session.isResolved) {
        await _session.clear(forgetToken: false);
      }
    }
  }

  Future<Result<User>> signIn({
    required String email,
    required String password,
  }) async {
    final result = await _repository.signIn(email: email, password: password);
    switch (result) {
      case Ok(:final value):
        await _session.start(value.user, tokens: value.tokens);
        return Result.ok(value.user);
      case Error(:final error):
        return Result.error(error);
    }
  }

  Future<void> signOut() async {
    await _repository.signOut();
    await _session.clear();
  }
}
