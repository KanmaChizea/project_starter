import 'package:equatable/equatable.dart';

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
