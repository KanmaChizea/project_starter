import 'package:project_starter/core/session/session_service.dart';
import 'package:project_starter/core/session/user.dart';

import '../repositories/auth_repository.dart';

/// Auth flows (sign-in, sign-out). Records the result in [SessionService].
/// View models talk to this, never to repositories.
class AuthService {
  AuthService(this._repository, this._session);

  final AuthRepository _repository;
  final SessionService _session;

  Future<User> signIn({required String email, required String password}) async {
    final json = await _repository.signIn(email: email, password: password);
    final user = _userFromJson(json);
    _session.start(user);
    return user;
  }

  Future<void> signOut() async {
    await _repository.signOut();
    _session.clear();
  }

  User _userFromJson(Map<String, Object?> json) => User(
    id: json['id']! as String,
    email: json['email']! as String,
    displayName: json['name'] as String?,
  );
}
