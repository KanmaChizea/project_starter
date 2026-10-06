import 'package:project_starter/core/session/session_cubit.dart';
import 'package:project_starter/core/session/user.dart';

import '../repositories/auth_repository.dart';

class AuthService {
  AuthService(this._repository, this._session);

  final AuthRepository _repository;
  final SessionCubit _session;

  Future<void> restoreSession() async {
    if (_session.isResolved) return;
    try {
      final token = await _session.readToken();
      final user = token == null
          ? null
          : await _repository.fetchCurrentUser(token);
      if (user == null) {
        await _session.clear();
      } else {
        await _session.start(user);
      }
    } catch (_) {
      final cached = await _session.readCachedUser();
      if (cached != null) {
        await _session.start(cached);
      } else {
        await _session.clear(forgetToken: false);
      }
    }
  }

  Future<User> signIn({required String email, required String password}) async {
    final result = await _repository.signIn(email: email, password: password);
    await _session.start(result.user, token: result.token);
    return result.user;
  }

  Future<void> signOut() async {
    await _repository.signOut();
    await _session.clear();
  }
}
