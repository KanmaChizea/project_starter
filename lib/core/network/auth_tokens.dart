import 'package:equatable/equatable.dart';

import '../storage/secure_storage.dart';

class AuthTokens extends Equatable {
  const AuthTokens({required this.accessToken, required this.refreshToken});

  factory AuthTokens.fromJson(Map<String, Object?> json) => AuthTokens(
    accessToken: json['accessToken']! as String,
    refreshToken: json['refreshToken']! as String,
  );

  final String accessToken;
  final String refreshToken;

  @override
  List<Object?> get props => [accessToken, refreshToken];
}

extension SaveAuthTokens on SecureStorage {
  Future<void> saveTokens(AuthTokens tokens) async {
    await write(SecureStorageKey.accessToken, tokens.accessToken);
    await write(SecureStorageKey.refreshToken, tokens.refreshToken);
  }
}
