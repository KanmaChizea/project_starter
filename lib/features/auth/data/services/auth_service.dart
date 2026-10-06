import 'package:project_starter/core/network/network_exception.dart';
import 'package:project_starter/core/session/session_cubit.dart';
import 'package:project_starter/core/session/user.dart';
import 'package:project_starter/core/utils/result.dart';

import '../repositories/auth_repository.dart';

class AuthService {
  AuthService(this._repository, this._session);

  final AuthRepository _repository;
  final SessionCubit _session;

  Future<void> restoreSession() async {
    if (_session.isResolved) return;
    if (await _session.readAccessToken() == null) {
      return _session.clear();
    }

    switch (await _repository.fetchCurrentUser()) {
      case Ok(:final value):
        await _session.start(value);
      case Error(error: UnauthorizedException()):
        await _session.clear();
      case Error():
        final cached = await _session.readCachedUser();
        if (cached != null) {
          await _session.start(cached);
        } else {
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

  Future<Result<void>> signOut() async {
    final result = await _repository.signOut();
    await _session.clear();
    return result;
  }
}
