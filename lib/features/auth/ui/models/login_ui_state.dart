import 'package:equatable/equatable.dart';

/// Everything the login screen needs to render.
class LoginUiState extends Equatable {
  const LoginUiState({
    this.email = '',
    this.password = '',
    this.isSubmitting = false,
    this.errorMessage,
  });

  final String email;
  final String password;
  final bool isSubmitting;
  final String? errorMessage;

  @override
  List<Object?> get props => [email, password, isSubmitting, errorMessage];

  bool get canSubmit =>
      !isSubmitting && email.contains('@') && password.isNotEmpty;

  LoginUiState copyWith({
    String? email,
    String? password,
    bool? isSubmitting,
    String? Function()? errorMessage,
  }) {
    return LoginUiState(
      email: email ?? this.email,
      password: password ?? this.password,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
    );
  }
}
