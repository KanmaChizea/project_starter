/// Data access for authentication (API, SDK, local storage, etc.).
///
/// Repositories return transport-level data; services turn it into entities.
abstract interface class AuthRepository {
  Future<Map<String, Object?>> signIn({
    required String email,
    required String password,
  });

  Future<void> signOut();
}

/// In-memory implementation until a real backend is wired up.
/// Accepts any email with a password of at least 6 characters.
class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({this.delay = const Duration(milliseconds: 600)});

  final Duration delay;

  @override
  Future<Map<String, Object?>> signIn({
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(delay);
    if (password.length < 6) {
      throw Exception('Invalid email or password.');
    }
    return {'id': 'fake-${email.hashCode}', 'email': email, 'name': null};
  }

  @override
  Future<void> signOut() => Future<void>.delayed(delay);
}
