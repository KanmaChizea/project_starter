import 'package:equatable/equatable.dart';
import 'package:project_starter/core/session/user.dart';

/// Everything the login screen needs to render.
class LoginUiState extends Equatable {
  const LoginUiState({
    this.email = '',
    this.password = '',
    this.isSubmitting = false,
    this.errorMessage,
    this.user,
  });

  final String email;
  final String password;
  final bool isSubmitting;
  final String? errorMessage;

  /// Set once sign-in succeeds.
  final User? user;

  @override
  List<Object?> get props => [
    email,
    password,
    isSubmitting,
    errorMessage,
    user,
  ];

  bool get canSubmit =>
      !isSubmitting && email.contains('@') && password.isNotEmpty;

  LoginUiState copyWith({
    String? email,
    String? password,
    bool? isSubmitting,
    String? Function()? errorMessage,
    User? Function()? user,
  }) {
    return LoginUiState(
      email: email ?? this.email,
      password: password ?? this.password,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
      user: user != null ? user() : this.user,
    );
  }
}
