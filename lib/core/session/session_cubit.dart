import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../network/auth_tokens.dart';
import '../storage/secure_storage.dart';
import 'session_state.dart';
import 'user.dart';

class SessionCubit extends Cubit<SessionState> {
  SessionCubit() : super(const SessionState.unknown());

  final _storage = SecureStorage();

  static const _sessionKeys = [
    SecureStorageKey.accessToken,
    SecureStorageKey.refreshToken,
    SecureStorageKey.cachedUser,
  ];

  User? get user => state.user;

  bool get isSignedIn => state.isSignedIn;

  bool get isResolved => state.isResolved;

  Future<String?> readAccessToken() =>
      _storage.read(SecureStorageKey.accessToken);

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

  /// Pass [tokens] on sign-in; omit them when restoring with stored tokens.
  Future<void> start(User user, {AuthTokens? tokens}) async {
    if (tokens != null) await _storage.saveTokens(tokens);
    await _storage.write(
      SecureStorageKey.cachedUser,
      jsonEncode(user.toJson()),
    );
    emit(SessionState.authenticated(user));
  }

  /// Signs out. [forgetToken] false keeps the stored tokens, e.g. when they
  /// could not be checked because the device is offline.
  Future<void> clear({bool forgetToken = true}) async {
    if (forgetToken) {
      for (final key in _sessionKeys) {
        await _storage.delete(key);
      }
    }
    if (state.status == SessionStatus.unauthenticated) return;
    emit(const SessionState.unauthenticated());
  }
}
