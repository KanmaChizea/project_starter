import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../storage/secure_storage.dart';
import 'session_state.dart';
import 'user.dart';

class SessionCubit extends Cubit<SessionState> {
  SessionCubit(this._storage) : super(const SessionState.unknown());

  final SecureStorage _storage;

  User? get user => state.user;

  bool get isSignedIn => state.isSignedIn;

  bool get isResolved => state.isResolved;

  Future<String?> readToken() => _storage.read(SecureStorageKey.accessToken);

  Future<User?> readCachedUser() async {
    final raw = await _storage.read(SecureStorageKey.cachedUser);
    if (raw == null) return null;
    try {
      return User.fromJson(jsonDecode(raw) as Map<String, Object?>);
    } on Object {
      await _storage.delete(SecureStorageKey.cachedUser);
      return null;
    }
  }

  /// Pass [token] on sign-in; omit it when restoring with the stored token.
  Future<void> start(User user, {String? token}) async {
    if (token != null) {
      await _storage.write(SecureStorageKey.accessToken, token);
    }
    await _storage.write(
      SecureStorageKey.cachedUser,
      jsonEncode(user.toJson()),
    );
    emit(SessionState.authenticated(user));
  }

  /// Signs out. [forgetToken] false keeps the stored token, e.g. when it
  /// could not be checked because the device is offline.
  Future<void> clear({bool forgetToken = true}) async {
    if (forgetToken) await _storage.clear();
    if (state.status == SessionStatus.unauthenticated) return;
    emit(const SessionState.unauthenticated());
  }
}
