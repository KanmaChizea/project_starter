import 'dart:convert';

import 'package:project_starter/core/session/user.dart';

import '../models/sign_in_result.dart';

abstract interface class AuthRepository {
  Future<SignInResult> signIn({
    required String email,
    required String password,
  });

  Future<User?> fetchCurrentUser(String token);

  Future<void> signOut();
}

class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({this.delay = const Duration(milliseconds: 600)});

  final Duration delay;

  static const _tokenPrefix = 'fake-token.';

  @override
  Future<SignInResult> signIn({
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(delay);
    if (password.length < 6) {
      throw Exception('Invalid email or password.');
    }
    return SignInResult(
      token: '$_tokenPrefix${base64Url.encode(utf8.encode(email))}',
      user: _user(email),
    );
  }

  @override
  Future<User?> fetchCurrentUser(String token) async {
    await Future<void>.delayed(delay);
    if (!token.startsWith(_tokenPrefix)) return null;
    try {
      final email = utf8.decode(
        base64Url.decode(token.substring(_tokenPrefix.length)),
      );
      return _user(email);
    } on FormatException {
      return null;
    }
  }

  @override
  Future<void> signOut() => Future<void>.delayed(delay);

  User _user(String email) => User(id: 'fake-${email.hashCode}', email: email);
}
