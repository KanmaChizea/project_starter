import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project_starter/core/session/session_service.dart';
import 'package:project_starter/core/session/user.dart';
import 'package:project_starter/features/auth/data/repositories/auth_repository.dart';
import 'package:project_starter/features/auth/data/services/auth_service.dart';
import 'package:project_starter/features/auth/ui/models/login_ui_state.dart';
import 'package:project_starter/features/auth/ui/views/login_view_model.dart';

void main() {
  late SessionService session;
  late AuthService authService;

  const email = 'jane@example.com';
  const filled = LoginUiState(email: email, password: 'secret123');

  setUp(() {
    session = SessionService();
    authService = AuthService(
      FakeAuthRepository(delay: Duration.zero),
      session,
    );
  });

  LoginViewModel build() => LoginViewModel(authService: authService);

  test('cannot submit until email and password are valid', () {
    final viewModel = build();
    addTearDown(viewModel.close);
    expect(viewModel.state.canSubmit, isFalse);

    viewModel
      ..onEmailChanged('not-an-email')
      ..onPasswordChanged('secret123');
    expect(viewModel.state.canSubmit, isFalse);

    viewModel.onEmailChanged(email);
    expect(viewModel.state.canSubmit, isTrue);
  });

  blocTest<LoginViewModel, LoginUiState>(
    'successful sign-in emits submitting, then the user, and starts the session',
    build: build,
    seed: () => filled,
    act: (viewModel) => viewModel.submit(),
    expect: () => [
      filled.copyWith(isSubmitting: true),
      isA<LoginUiState>()
          .having((s) => s.isSubmitting, 'isSubmitting', false)
          .having((s) => s.user?.email, 'user.email', email),
    ],
    verify: (_) => expect(session.user, isA<User>()),
  );

  blocTest<LoginViewModel, LoginUiState>(
    'failed sign-in emits an error and leaves the session empty',
    build: build,
    seed: () => filled.copyWith(password: '123'),
    act: (viewModel) => viewModel.submit(),
    expect: () => [
      filled.copyWith(password: '123', isSubmitting: true),
      isA<LoginUiState>()
          .having((s) => s.isSubmitting, 'isSubmitting', false)
          .having((s) => s.errorMessage, 'errorMessage', isNotNull),
    ],
    verify: (_) => expect(session.isSignedIn, isFalse),
  );

  blocTest<LoginViewModel, LoginUiState>(
    'editing a field clears the error',
    build: build,
    seed: () => filled.copyWith(errorMessage: () => 'Oops'),
    act: (viewModel) => viewModel.onPasswordChanged('secret1234'),
    expect: () => [filled.copyWith(password: 'secret1234')],
  );
}
