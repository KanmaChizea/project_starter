import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/services/auth_service.dart';
import '../models/login_ui_state.dart';

class LoginViewModel extends Cubit<LoginUiState> {
  LoginViewModel({required this._authService}) : super(const LoginUiState());

  final AuthService _authService;

  void onEmailChanged(String value) =>
      emit(state.copyWith(email: value.trim(), errorMessage: () => null));

  void onPasswordChanged(String value) =>
      emit(state.copyWith(password: value, errorMessage: () => null));

  Future<void> submit() async {
    if (!state.canSubmit) return;
    emit(state.copyWith(isSubmitting: true, errorMessage: () => null));

    try {
      final user = await _authService.signIn(
        email: state.email,
        password: state.password,
      );
      if (isClosed) return;
      emit(state.copyWith(isSubmitting: false, user: () => user));
    } catch (_) {
      if (isClosed) return;
      emit(
        state.copyWith(
          isSubmitting: false,
          errorMessage: () => 'Something went wrong. Please try again.',
        ),
      );
    }
  }
}
