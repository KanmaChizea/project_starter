import 'package:equatable/equatable.dart';
import 'package:project_starter/core/network/auth_tokens.dart';
import 'package:project_starter/core/session/user.dart';

class SignInResult extends Equatable {
  const SignInResult({required this.tokens, required this.user});

  factory SignInResult.fromJson(Map<String, Object?> json) => SignInResult(
    tokens: AuthTokens.fromJson(json),
    user: User.fromJson(json['user']! as Map<String, Object?>),
  );

  final AuthTokens tokens;
  final User user;

  @override
  List<Object?> get props => [tokens, user];
}
