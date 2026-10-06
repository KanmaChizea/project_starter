import 'package:equatable/equatable.dart';
import 'package:project_starter/core/session/user.dart';

class SignInResult extends Equatable {
  const SignInResult({required this.token, required this.user});

  final String token;
  final User user;

  @override
  List<Object?> get props => [token, user];
}
